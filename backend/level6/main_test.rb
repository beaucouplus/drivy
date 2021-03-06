require 'minitest/autorun'
require_relative 'main'
require 'fileutils'

class DrivyTest < Minitest::Test
  def setup
    @example_json = import_json("output.json")
    @generated = "generated.json"
  end

  def test_output_json_and_data_json_should_be_equivalent
    File.delete(@generated) if File.exist?(@generated)
    Rental.reset
    Car.reset
    RentalModification.reset
    CreateObjects.new(import_json("data.json")).call
    save_json
    output = import_json(@generated)
    assert_equal @example_json, output
  end

end

class CarTest < Minitest::Test

  def test_self_reset_should_empty_all_arrays
    Car.reset
    assert_empty Car.all
  end

  def test_should_return_an_array_populated_with_one_Car_item
    Car.reset
    Car.new({ "id": 1, "price_per_day": 4000, "price_per_km": 10 })
    assert_kind_of Array, Car.all
    assert_equal 1, Car.all.size
    assert_kind_of Car, Car.all.first
  end

  def test_param_values_should_be_encapsulated_in_the_object
    Car.reset
    Car.new({ "id": 1, "price_per_day": 4000, "price_per_km": 10 })
    first_car = Car.all.first
    assert_equal 1, first_car.id
    assert_equal 4000, first_car.price_per_day
    assert_equal 10, first_car.price_per_km
  end

  def test_should_raise_error_when_price_per_day_under_0
    assert_raises ArgumentError do
      Car.new({ "id": 1, "price_per_day": -1, "price_per_km": 10 })
    end
  end

  def test_should_raise_error_when_price_per_km_under_0
    assert_raises ArgumentError do
      Car.new({ "id": 1, "price_per_day": 10, "price_per_km": -1 })
    end
  end

end

class CommissionTest < Minitest::Test

  def test_should_return_a_hash_with_three_values
    commission = Commission.new(10000, 5)
    result = {:insurance_fee=>1500, :assistance_fee=>500, :drivy_fee=>1000}
    assert_equal result, commission.call
  end

  def test_should_raise_error_if_first_param_divided_by_second_param_is_below_1000
    assert_raises ArgumentError do
      Commission.new(2000, 4).call
    end
  end

end

class DeductibleReductionTest < Minitest::Test

  def test_should_return_5_times_400
    deductible = DeductibleReduction.new(5, true)
    assert_equal 2000, deductible.call
  end

  def test_should_return_0
    deductible = DeductibleReduction.new(5, false)
    assert_equal 0, deductible.call
  end

  def test_should_raise_error_if_rental_length_equal_or_inferior_to_0
    assert_raises ArgumentError do
      DeductibleReduction.new(0, false)
    end
  end

end

class SumPricesPerDayTest < Minitest::Test

  def test_should_return_2000
    sum = SumPricesPerDay.new(1, 2000)
    assert_equal 2000, sum.call
  end

  def test_should_return_5600
    sum = SumPricesPerDay.new(3, 2000)
    assert_equal 5600, sum.call
  end

  def test_should_return_8800
    sum = SumPricesPerDay.new(5, 2000)
    assert_equal 8800, sum.call
  end

  def test_should_return_16800
    sum = SumPricesPerDay.new(11, 2000)
    assert_equal 16800, sum.call
  end

  def test_should_raise_error_if_length_inferior_to_0
    assert_raises ArgumentError do
      SumPricesPerDay.new(-1, 2000)
    end
  end

  def test_should_raise_error_if_price_per_day_inferior_to_0
    assert_raises ArgumentError do
      SumPricesPerDay.new(100, -1)
    end
  end

end

class StakeHoldersTest < Minitest::Test
  def setup
    @params = { total_price: 9000, deductible_amount: 400, commission: {:insurance_fee=>1500, :assistance_fee=>500, :drivy_fee=>1000} }
  end


  def test_should_return_a_array_of_hashes
    stakeholders = StakeHolders.new(@params)
    assert_kind_of Array, stakeholders.call
    assert_kind_of Hash, stakeholders.call[0]
  end

  def test_debit_and_credit_should_be_impacted_by_deductible
    stakeholders = StakeHolders.new(@params)
    assert_equal 9400, stakeholders.call.first[:amount]
    assert_equal 1400, stakeholders.call.last[:amount]
  end

  def test_owner_should_get_total_minus_commission
    stakeholders = StakeHolders.new(@params)
    assert_equal 6000, stakeholders.call[1][:amount]
  end

  def test_renter_action_param_should_impact_rental_type
    stakeholders = StakeHolders.new(@params, :credit)
    assert_equal :credit, stakeholders.call[0][:type]
    assert_equal :debit,  stakeholders.call[1][:type]
  end

  def test_should_raise_error_if_total_price_inferior_to_0
    @params[:total_price] = -1
    assert_raises ArgumentError do
      StakeHolders.new(@params)
    end
  end

  def test_should_raise_error_if_deductible_amount_inferior_to_0
    @params[:deductible_amount] = -1
    assert_raises ArgumentError do
      StakeHolders.new(@params)
    end
  end

  def test_should_raise_error_if_commission_doesnt_have_required_keys
    @params[:commission] = { pi: "ka", chu: "kale" }
    assert_raises ArgumentError do
      StakeHolders.new(@params)
    end
  end

end


class RentalTest < Minitest::Test

  def setup
    Rental.reset
    Car.reset
    @params = {
      "id": 1, "car_id": 1, "start_date": "2015-12-8",
      "end_date": "2015-12-8", "distance": 100, "deductible_reduction": true
    }
    Car.new({ "id": 1, "price_per_day": 2000, "price_per_km": 10 })
    Rental.new(@params)
  end

  def test_self_reset_should_empty_all_arrays
    Rental.reset
    assert_empty Rental.all
    assert_empty Rental.price_data[:rentals]
    assert_empty Rental.stakeholders[:rentals]
  end

  def test_should_return_an_array_populated_with_one_Rental_item
    assert_kind_of Array, Rental.all
    assert_equal 1, Rental.all.size
    assert_kind_of Rental, Rental.all.first
  end

  def test_param_values_should_be_encapsulated_in_the_object
    first_rental = Rental.all.first
    assert_equal 1, first_rental.id
    assert_equal "2015-12-8", first_rental.start_date
    assert_equal 100, first_rental.distance
  end

  def test_price_data_should_be_a_hash
    assert_kind_of Hash, Rental.price_data
  end

  def test_price_data_should_return_a_jon_with_computed_data
    result = {:rentals=>[
                {:id=>1, :price=>3000,
                 :options=>{:deductible_reduction=>400},
                 :commission=>{:insurance_fee=>450, :assistance_fee=>100, :drivy_fee=>350}
                 }
    ]}
    assert_equal result, Rental.price_data
  end

  def test_stakeholders_should_return_a_hash
    assert_kind_of Hash, Rental.stakeholders
  end

  def test_stakeholders_should_return_a_hash
    result = {:rentals=>[{:id=>1, :actions=>[
                            {:who=>:driver, :type=>:debit, :amount=>3400},
                            {:who=>:owner, :type=>:credit, :amount=>2100},
                            {:who=>:insurance, :type=>:credit, :amount=>450},
                            {:who=>:assistance, :type=>:credit, :amount=>100},
                            {:who=>:drivy, :type=>:credit, :amount=>750}
    ]}]}
    assert_equal result, Rental.stakeholders
  end

  def test_should_raise_error_if_start_date_is_wrongly_formatted
    @params[:start_date] = "kikou"
    assert_raises ArgumentError do
      Rental.new(@params)
    end
  end

  def test_should_raise_error_if_end_date_is_wrongly_formatted
    @params[:end_date] = "kikou"
    assert_raises ArgumentError do
      Rental.new(@params)
    end
  end

  def test_should_raise_error_if_distance_equal_inferior_to_0
    @params[:distance] = 0
    assert_raises ArgumentError do
      Rental.new(@params)
    end
  end

end

class CreateObjectsTest < Minitest::Test

  def setup
    Car.reset
    Rental.reset
    RentalModification.reset
    CreateObjects.new(import_json("data.json")).call
  end

  def test_objects_should_be_populated
    assert_equal 1, Car.all.size
    assert_equal 3, Rental.all.size
  end

  def test_objects_should_be_of_the_correct_class
    assert_kind_of Car, Car.all.first
    assert_kind_of Rental, Rental.all.first
  end

end

class RentalModificationTest < Minitest::Test

  def setup
    Rental.reset
    Car.reset
    RentalModification.reset

    Car.new({ "id": 1, "price_per_day": 2000, "price_per_km": 10 })
    rental_params = {
      "id": 1, "car_id": 1, "start_date": "2015-12-8",
      "end_date": "2015-12-8", "distance": 100, "deductible_reduction": true
    }
    Rental.new(rental_params)
    @mod_params = { "id": 1, "rental_id": 1, "end_date": "2015-12-10", "distance": 150 }
    RentalModification.new(@mod_params)
  end

  def test_should_return_an_array_populated_with_one_Rental_item
    assert_kind_of Array, RentalModification.all
    assert_equal 1, RentalModification.all.size
    assert_kind_of RentalModification, RentalModification.all.first
  end

  def test_param_values_should_be_encapsulated_in_the_object
    first_rentalmod = RentalModification.all.first
    assert_equal 1, first_rentalmod.rental.id
    assert_equal 150, first_rentalmod.distance
  end

  def test_stakeholders_should_be_a_hash
    assert_kind_of Hash, RentalModification.stakeholders
  end

  def test_stakeholders_should_return_a_jon_with_computed_data
    result = {:rental_modifications=>[
                {:id=>1, :rental_id=>1, :actions=>[
                   {:who=>:driver, :type=>:debit, :amount=>4900},
                   {:who=>:owner, :type=>:credit, :amount=>2870},
                   {:who=>:insurance, :type=>:credit, :amount=>615},
                   {:who=>:assistance, :type=>:credit, :amount=>200},
                   {:who=>:drivy, :type=>:credit, :amount=>1215}
    ]}]}
    assert_equal result, RentalModification.stakeholders
  end

  def test_should_raise_error_if_start_date_is_wrongly_formatted
    @mod_params[:start_date] = "kikou"
    assert_raises ArgumentError do
      Rental.new(@mod_params)
    end
  end

  def test_should_raise_error_if_end_date_is_wrongly_formatted
    @mod_params[:end_date] = "kikou"
    assert_raises ArgumentError do
      Rental.new(@mod_params)
    end
  end

  def test_should_raise_error_if_distance_equal_inferior_to_0
    @mod_params[:distance] = 0
    assert_raises ArgumentError do
      Rental.new(@mod_params)
    end
  end

end

class RentalModificationTest < Minitest::Test

  def test_msg_should_encapsulate_a_list_of_messages
    assert_equal "Price divided by length should at least equal 1000", Error.msg[:commission]
    message = "Wrong commission parameters. Should include assistance_fee, drivy_fee and insurance_fee"
    assert_equal message, Error.msg[:wrong_commision_parameters]
  end
end
