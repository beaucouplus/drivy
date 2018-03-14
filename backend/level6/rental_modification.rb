class RentalModification < Rental

  class << self
    attr_accessor :instances, :stakeholders
  end
  @instances = []
  @stakeholders = { rental_modifications: [] }

  attr_reader :id, :rental, :car, :start_date, :end_date, :distance, :deductible_reduction

  def initialize(params)
    @id = params[:id]
    @rental = set_rental(params[:rental_id])
    @car = rental.car
    @deductible_reduction = rental.deductible_reduction
    @start_date = params.fetch(:start_date, rental.start_date)
    @end_date = params.fetch(:end_date, rental.end_date)
    @distance = params.fetch(:distance, rental.distance)
    RentalModification.instances << self
    RentalModification.stakeholders[:rental_modifications] << actions_summary
  end

  def self.reset
    @instances.clear
    @stakeholders[:rental_modifications].clear
  end


  private

  def actions_summary
    { id: id, rental_id: rental.id, actions: updated_actions }
  end

  def delta_price
    delta_price = total_price - rental.summary[:price]
  end

  def delta_length
    length - rental.length
  end

  def delta_commission
    Commission.new(delta_price.abs, delta_length.abs).call
  end

  def delta_deductible_reduction
    deductible_amount - rental.summary[:options][:deductible_reduction]
  end

  def updated_actions
    if delta_price < 0
      StakeHolders.new(delta_price.abs, delta_commission, delta_deductible_reduction.abs, :credit).call
    else
      StakeHolders.new(delta_price.abs, delta_commission, delta_deductible_reduction.abs).call
    end
  end

  def set_rental(param)
    Rental.all.find{ |rental| rental.id == param }
  end

end
