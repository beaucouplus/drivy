require 'minitest/autorun'
require_relative 'main'
require 'fileutils'

class DrivyTest < Minitest::Test
  def setup
    @example_json = import_json("output.json")
  end

  def test_output_json_and_data_json_should_be_equivalent
    File.delete("generated.json")
    save_json
    output = import_json("generated.json")
    assert_equal @example_json, output
  end

end
