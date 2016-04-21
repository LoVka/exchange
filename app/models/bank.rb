class Bank
  include Mongoid::Document

  field :content, type: Hash
  before_create :save_to_i
  validate :validate_coins
  NOMINAL_COINS = [1, 2, 5, 10, 25, 50, 100]

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
    bank.content.each { |k, v| total_bank += k.to_i * v }

    raise ExchangeError, 'Sorry, not enough money for exchange' if total_bank < need_change

    change = {}

    bank.content.each do |k, v|
      need_coins = need_change / k.to_i
      if v >= need_coins
        change[k]       = need_coins
        bank.content[k] = bank.content[k] - need_coins
        need_change     -= k.to_i * need_coins
        break if need_change == 0
      else
        change[k]       = v
        bank.content[k] = (bank.content[k] - v)
        need_change     -= k.to_i * v
      end
    end

    raise ExchangeError, 'Sorry, there are no coins to correctly exchange' unless need_change == 0
    bank.save
    { msg: Bank.pretty(change) }
  end

  private

  def save_to_i
    self.content = Hash[content.map { |k, v| [k.to_i, v.to_i] }.sort_by { |k, v| -k }]
  end

  def validate_coins
    invalid_coins = content.keys.map(&:to_i) - NOMINAL_COINS
    if invalid_coins.any?
      errors.add(:content, "includes invalid coins. Plese, use nominal coins: #{NOMINAL_COINS.join(', ')}")
    end
  end
end
