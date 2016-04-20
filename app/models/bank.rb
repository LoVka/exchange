class Bank
  include Mongoid::Document

  field :content, type: Hash

  def self.pretty(val)
    val    = val.sort_by { |k, v| -k.to_i }.map { |k, v| [k.to_i, v.to_i] }
    pretty = {}
    val.each do |k, v|
      if v > 1 && k > 1
        pretty["#{v} coins"] = "#{k} cents"
      elsif v > 1 && k == 1
        pretty["#{v} coins"] = "#{k} cent"
      elsif v == 1 && k > 1
        pretty["#{v} coin"] = "#{k} cents"
      elsif v == 1 && k == 1
        pretty["#{v} coin"] = "#{k} cent"
      end
    end
    pretty
  end

  ExchangeError = Class.new(StandardError)

  def self.exchange(params)
    bank        = Bank.last
    need_change = params[:need_change].to_i*100
    total_bank  = 0
    bank.content.each { |k, v| total_bank += k.to_i * v.to_i }

    if total_bank < need_change
      raise ExchangeError, 'Sorry, not enough money for exchange'
    else
      bank_content = bank.content.sort_by { |k, v| -k.to_i }
      change       = {}

      bank_content.each do |k, v|
        need_coins = need_change / k.to_i
        if v.to_i >= need_coins
          change[k]       = need_coins
          bank.content[k] = bank.content[k].to_i - need_coins
          bank.save
          need_change -= k.to_i * need_coins.to_i
          break if need_change == 0
        else
          change[k]       = v.to_i
          bank.content[k] = (bank.content[k].to_i - v.to_i)
          bank.save
          need_change -= k.to_i * v.to_i
        end

      end

      if need_change == 0
        { msg: Bank.pretty(change) }
      else
        raise ExchangeError, 'Sorry, there are no coins to correctly exchange'
      end
    end

  end

end