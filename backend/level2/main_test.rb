require 'minitest/autorun'
require_relative 'main'
require 'fileutils'

class DrivyTest < Minitest::Test
  def setup
    @example_json = import_json("output.json")
    @output_json = import_json("generated.json")
  end

  def test_output_json_and_data_json_should_be_equivalent
    assert_equal @example_json, @output_json
  end

end
