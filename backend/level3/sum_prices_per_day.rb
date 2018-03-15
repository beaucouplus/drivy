class SumPricesPerDay

  attr_reader :length, :price_per_day
  def initialize(length, price_per_day)
    @length = length
    @price_per_day = price_per_day
  end

  def call
    result = 0
    (1..length).each do |number|
      case
      when number > 1 && number < 5
        result += price_per_day * 0.9
      when number >= 5 && number <= 10
        result += price_per_day * 0.7
      when number > 10
        result += price_per_day * 0.5
      else
        result += price_per_day
      end
    end
    result
  end

end
