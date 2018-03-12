require "date"
require "json"
require "pp"
require_relative "car"
require_relative "commission"
require_relative "create_objects"
require_relative "deductible_reduction"
require_relative "rental"
require_relative "sum_prices_per_day"
require_relative "stakeholders"


def import_json(json)
  file = File.read(json)
  data = JSON.parse(file)
end

CreateObjects.new(import_json("data.json")).call

def save_json
  File.open("generated.json", 'w+'){ |file| file.write(JSON.pretty_generate(Rental.stakeholders)) }
end
