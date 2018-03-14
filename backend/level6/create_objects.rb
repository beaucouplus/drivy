class CreateObjects

  attr_accessor :data
  def initialize(data)
    @data = data
  end

  def call
    create_objects_from_keys_and_values
  end

  private

  def create_objects_from_keys_and_values
    data.each do |key, values|
      object = normalize(key)
      create_objects(values,object)
    end
  end

  def singularize(key)
    key.end_with?("s") ? key[0..-2] : key
  end

  def normalize(key)
    if key =~ /[_]/
      key = key.split('_').map(&:capitalize).join
      singularize(key)
    else
      key = key.capitalize
      singularize(key)
    end
  end

  def create_objects(array,object)
    array.each do |my_hash|
      create_one_object(my_hash,object)
    end
  end

  def create_one_object(my_hash,object)
    new_hash = symbolise_keys(my_hash)
    Object.const_get(object).new(new_hash)
  end

  def symbolise_keys(my_hash)
    Hash[my_hash.map { |key, value| [key.to_sym, value] }]
  end

end
