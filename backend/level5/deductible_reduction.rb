class DeductibleReduction

  attr_reader :length, :suscribed_to_option

  def initialize(rental_length, suscribed_to_option)
    @length = rental_length
    @suscribed_to_option = suscribed_to_option
  end

  def call
    define_deductible_amount
  end

  private
  DEDUCTIBLE_DAILY_CHARGE = 400

  def deductible_amount
    DEDUCTIBLE_DAILY_CHARGE * length
  end

  def define_deductible_amount
    suscribed_to_option ? deductible_amount : 0
  end

end
