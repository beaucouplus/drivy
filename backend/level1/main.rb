require "json"
require "pp"
require "date"

# your code
def import_json(json)
  file = File.read(json)
  data = JSON.parse(file)
end

data = import_json("data.json")

cars = data["cars"]
rentals = data["rentals"]

rentals_price = rentals.each_with_object({rentals: []}) do |rental, rentals_hash|
  car = cars.select{ |car| car["id"] == rental["car_id"] }.first
  distance_price = rental["distance"] * car["price_per_km"]

  rental_days_num = (Date.parse(rental["end_date"]) - Date.parse(rental["start_date"]) + 1).to_i
  time_price = rental_days_num * car["price_per_day"]

  total_price = distance_price + time_price
  rentals_hash[:rentals] << { id: rental["id"], price: total_price }
end

File.open("generated.json", 'w+'){ |file| file.write(JSON.pretty_generate(rentals_price))}
