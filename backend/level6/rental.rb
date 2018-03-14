class Rental

  class << self
    attr_accessor :instances, :price_data, :stakeholders
  end
  @instances = []
  @price_data = { rentals: [] }
  @stakeholders = { rentals: [] }



  attr_reader :id, :car, :start_date, :end_date, :distance, :deductible_reduction

  def initialize(params)
    @id = params[:id]
    @car = set_car(params[:car_id])
    @start_date = params[:start_date]
    @end_date = params[:end_date]
    @distance = params[:distance]
    @deductible_reduction = params[:deductible_reduction]
    Rental.instances << self
    Rental.price_data[:rentals] << summary.select{ |key,v| key != :actions }
    Rental.stakeholders[:rentals] << summary.select{ |key, v| [:id,:actions].include?(key) }
  end

  def self.all
    @instances
  end

  def self.reset
    @instances.clear
    @price_data[:rentals].clear
    @stakeholders[:rentals].clear
  end

  def self.price_data
    @price_data
  end

  def self.stakeholders
    @stakeholders
  end

  def summary
    { id: id, price: total_price, options: options, commission: commission, actions: actions }
  end

  def length
    (Date.parse(end_date) - Date.parse(start_date) + 1).to_i
  end

  private

  def total_price
    time_price.to_i + distance_price.to_i
  end

  def distance_price
    distance * car.price_per_km
  end

  def time_price
    SumPricesPerDay.new(length,car.price_per_day).call
  end

  def set_car(param)
    Car.all.find{ |car| car.id == param }
  end

  def options
    { deductible_reduction: deductible_amount }
  end

  def deductible_amount
    DeductibleReduction.new(length, deductible_reduction).call
  end

  def actions
    StakeHolders.new(total_price, commission, deductible_amount).call
  end

  def commission
    Commission.new(total_price, length).call
  end
end
