class StakeHolders


  attr_reader :total_price, :commission, :deductible, :renter_action
  attr_accessor :stakeholders
  def initialize(total_price, commission, deductible, renter_action = :debit)
    @total_price = total_price
    @commission = commission
    @deductible = deductible
    @renter_action = renter_action
    @stakeholders = { driver: [ renter_action, total_driver_debit ],
                      owner: [ current_action, total_owner_credit ],
                      insurance: [ current_action, commission[:insurance_fee] ],
                      assistance: [ current_action, commission[:assistance_fee] ],
                      drivy: [ current_action, total_drivy_credit ] }
  end

  def call
    generate_array_of_stakeholders
  end

  private

  def current_action
    renter_action == :debit ? :credit : :debit
  end

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
