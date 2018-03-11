require "date"
require "json"
require "pp"
require_relative "car"
require_relative "commission"
require_relative "create_objects"
require_relative "rental"
require_relative "set_price_per_day"

def import_json(json)
  file = File.read(json)
  data = JSON.parse(file)
end

CreateObjects.new(import_json("data.json")).call

def save_json
  File.open("generated.json", 'w+'){ |file| file.write(JSON.pretty_generate(Rental.price_data)) }
end
