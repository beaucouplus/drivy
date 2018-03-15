class Car

  @@instances = []
  attr_reader :id, :price_per_day, :price_per_km

  def initialize(params)
    raise ArgumentError.new(Error.msg[:under_0]) if params[:price_per_day] < 0 || params[:price_per_km] < 0
    @id = params[:id]
    @price_per_day = params[:price_per_day]
    @price_per_km = params[:price_per_km]
    @@instances << self
  end

  def self.all
    @@instances
  end

  def self.reset
    @@instances = []
  end
end
