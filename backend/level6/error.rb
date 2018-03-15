module Error

  def self.msg
    {
      commission: "Price divided by length should at least equal 1000",
      under_0: "values cannot be inferior to 0",
      equal_or_under_0: "values cannot be equal or inferior to 0",
      wrong_date: "Incorrect date format",
      wrong_commision_parameters: "Wrong commission parameters. Should include assistance_fee, drivy_fee and insurance_fee"
    }
  end

  def self.check_dates(date)
    begin
      Date.parse(date)
    rescue => e
      raise ArgumentError.new(Error.msg[:wrong_date])
    end
  end


end
