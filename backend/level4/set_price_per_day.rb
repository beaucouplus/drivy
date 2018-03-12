class SetPricePerDay

  attr_reader :length, :price_per_day
  def initialize(length, price_per_day)
    @length = length
    @price_per_day = price_per_day
  end

  def call
    sum_reduced_prices
  end

  private
  def sum_reduced_prices
    (1..length).sum do |number|
      calculate_reduced_price_per_day(number)
    end
  end

  def calculate_reduced_price_per_day(number)
    return price_per_day * 0.9 if ten_percent_range(number)
    return price_per_day * 0.7 if thirty_percent_range(number)
    return price_per_day * 0.5 if fifty_percent_range(number)
    price_per_day
  end

  def ten_percent_range(number)
    number > 1 && number < 5
  end

  def thirty_percent_range(number)
    number >= 5 && number <= 10
  end

  def fifty_percent_range(number)
    number > 10
  end

end
