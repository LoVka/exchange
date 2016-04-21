class Bank
  include Mongoid::Document

  field :content, type: Hash

  def self.pretty(val)
    val    = val.map { |k, v| [k.to_i, v.to_i] }.sort_by { |k, v| -k }
    pretty = {}
    val.each do |k, v|
      next if v == 0
      pretty["#{k} cent#{'s' if k > 1}"] = "#{v} coin#{'s' if v > 1}"
    end
    pretty
  end

  ExchangeError = Class.new(StandardError)

  def self.exchange(need_change)
    bank        = Bank.last || raise(ExchangeError, "Sorry, bank not initialized yet")
    need_change = need_change * 100
    total_bank  = 0
    bank.content.each { |k, v| total_bank += k.to_i * v.to_i }

    raise ExchangeError, 'Sorry, not enough money for exchange' if total_bank < need_change

    bank_content = bank.content.sort_by { |k, v| -k.to_i }
    change       = {}

    bank_content.each do |k, v|
      need_coins = need_change / k.to_i
      if v.to_i >= need_coins
        change[k]       = need_coins
        bank.content[k] = bank.content[k].to_i - need_coins
        need_change -= k.to_i * need_coins.to_i
        break if need_change == 0
      else
        change[k]       = v.to_i
        bank.content[k] = (bank.content[k].to_i - v.to_i)
        need_change -= k.to_i * v.to_i
      end
    end

    raise ExchangeError, 'Sorry, there are no coins to correctly exchange' unless need_change == 0
    bank.save
    { msg: Bank.pretty(change) }
  end
end
