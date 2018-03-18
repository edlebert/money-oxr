require 'money_oxr/rates_store'
require 'money/bank/variable_exchange'

module MoneyOXR
  class Bank < Money::Bank::VariableExchange

    def initialize(options={}, &block)
      super(MoneyOXR::RatesStore.new(options), &block)
    end

  end
end
