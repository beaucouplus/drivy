class StakeHolders

  CREDIT = "credit"
  attr_reader :total_price, :commission, :deductible
  attr_accessor :stakeholders
  def initialize(total_price, commission, deductible)
    @total_price = total_price
    @commission = commission
    @deductible = deductible
    @stakeholders = { driver: [ "debit", total_driver_debit ],
                      owner: [ CREDIT, total_owner_credit ],
                      insurance: [ CREDIT, commission[:insurance_fee] ],
                      assistance: [ CREDIT, commission[:assistance_fee] ],
                      drivy: [ CREDIT, total_drivy_credit ] }
  end

  def call
    generate_array_of_stakeholders
  end

  private

  def generate_array_of_stakeholders
    stakeholders.each_with_object([]) do |(who,type_and_amount), array|
      type = type_and_amount.first
      amount = type_and_amount.last
      array << add_stakeholder(who, type, amount)
    end
  end

  def total_driver_debit
    total_price + deductible
  end

  def total_drivy_credit
    commission[:drivy_fee] + deductible
  end

  def total_owner_credit
    total_price - commission.sum{ |key,value| value }
  end

  def add_stakeholder(who,type,amount)
    { who: who, type: type, amount: amount }
  end

end
