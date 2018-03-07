require 'minitest/autorun'
require_relative 'main'
# require 'fileutils'

class DrivyTest < Minitest::Test
  def setup
    @example_json = "output.json"
    @output_json = "generated.json"
  end

  def test_output_json_and_data_json_should_be_equivalent
    assert true, FileUtils.compare_file(@output_json, @example_json)
  end

end
