require 'spec_helper'

RSpec.describe MoneyOXR::Bank do

  it 'creates a Money::Bank::VariableExchange with a MoneyOXR::RateStore' do
    subject = described_class.new(
      app_id: 'abcd1234',
      cache_path: 'tmp/data.json',
      max_age: 86400,
      source: 'GBP'
    )
    expect(subject.store).to be_a MoneyOXR::RatesStore
    expect(subject.store.app_id).to eq 'abcd1234'
    expect(subject.store.cache_path).to eq 'tmp/data.json'
    expect(subject.store.max_age).to eq 86400
    expect(subject.store.source).to eq 'GBP'
  end

end
