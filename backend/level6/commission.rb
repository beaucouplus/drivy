class Commission

  attr_reader :commission, :rental_length

  def initialize(rental_price, rental_length)
    raise ArgumentError.new(Error.msg[:commission]) if rental_price / rental_length < 1000
    @commission = calculate_commission(rental_price)
    @rental_length = rental_length
  end

  def call
    {
      insurance_fee: insurance_fee.to_i,
      assistance_fee: assistance_fee.to_i,
      drivy_fee: drivy_fee.to_i
    }
  end

  private

  def calculate_commission(rental_price)
    rental_price * 0.3
  end

  def insurance_fee
    commission / 2
  end

  def assistance_fee
    rental_length * 100
  end

  def drivy_fee
    commission - insurance_fee - assistance_fee
  end

end
