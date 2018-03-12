class Rental

  @@instances = []
  @@price_data = { rentals: [] }
  attr_reader :id, :car, :start_date, :end_date, :distance, :deductible_reduction

  def initialize(params)
    @id = params[:id]
    @car = set_car(params[:car_id])
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @distance = params[:distance]
    @deductible_reduction = params[:deductible_reduction]
    @@instances << self
    @@price_data[:rentals] << { id: id, price: total_price, options: options, commission: commission }
  end

  def self.all
    @@instances
  end

  def self.price_data
    @@price_data
  end

  private

  def total_price
    time_price.to_i + distance_price.to_i
  end

  def length
    (Date.parse(end_date) - Date.parse(start_date) + 1).to_i
  end

  def commission
    Commission.new(total_price, length).call
  end

  def distance_price
    distance * car.price_per_km
  end

  def time_price
    SetPricePerDay.new(length,car.price_per_day).call
  end

  def set_car(param)
    Car.all.select{ |car| car.id == param }.first
  end

  def options
    DeductibleReduction.new(length, deductible_reduction).call
  end


end
