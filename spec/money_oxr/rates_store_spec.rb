require 'spec_helper'
require 'fileutils'

RSpec.describe MoneyOXR::RatesStore do

  let(:json_path) { File.join('spec', 'data.json') }
  let(:json_string) { File.read(json_path) }
  let(:tmp_cache_path) do
    FileUtils.mkdir_p('tmp')
    tmp_cache_path = File.join('tmp', 'data.json')
    FileUtils.rm_f(tmp_cache_path)
    tmp_cache_path
  end

  describe '#source' do
    it 'defaults to USD' do
      expect(subject.source).to eq 'USD'
    end
    it 'can be over-ridden using :source option' do
      subject = described_class.new source: 'GBP'
      expect(subject.source).to eq 'GBP'
    end
  end

  describe '#cache_path' do
    it 'defaults to nil' do
      expect(subject.cache_path).to be nil
    end
    it 'returns :cache_path option' do
      subject = described_class.new cache_path: 'tmp/oxr-cache.json'
      expect(subject.cache_path).to eq 'tmp/oxr-cache.json'
    end
  end

  describe '#get_rate' do
    it 'returns rates from source' do
      subject = described_class.new(cache_path: json_path)
      expect(subject.get_rate('USD', 'EUR')).to eq BigDecimal.new('0.813255')
    end
    it 'adds and returns inverse rates to source' do
      subject = described_class.new(cache_path: json_path)
      expect(subject.get_rate('EUR', 'USD')).to eq BigDecimal.new('1.229626624')
    end
    it 'adds and returns calculated rates using source as an intermediary' do
      subject = described_class.new(cache_path: json_path)
      expect(subject.get_rate('CAD', 'EUR')).to eq BigDecimal.new('0.620734267068656260733503797390795')
    end
    it 'raises UnsupportedCurrency if currency is unsupported' do
      subject = described_class.new(cache_path: json_path)
      expect {
        subject.get_rate('USD', 'FOO')
      }.to raise_error(described_class::UnsupportedCurrency, 'FOO')
      expect {
        subject.get_rate('FOO', 'USD')
      }.to raise_error(described_class::UnsupportedCurrency, 'FOO')
      expect {
        subject.get_rate('FOO', 'BAR')
      }.to raise_error(described_class::UnsupportedCurrency, 'FOO')
    end
  end

  describe '#load' do
    it 'loads from cache file if provided' do
      subject = described_class.new(cache_path: json_path)
      expect(subject.loaded?).to be false
      subject.load
      expect(subject.loaded?).to be true
    end
    it 'loads from api if data is stale, while saving through tmp_cache_path' do
      subject = described_class.new(app_id: 'abc1234', cache_path: tmp_cache_path, max_age: 0)
      expect(subject.loaded?).to be false
      stub_api(app_id: 'abc1234', source: 'USD')
      subject.load
      expect(subject.loaded?).to be true
      expect(File.read(tmp_cache_path)).not_to eq json_string
    end
    it 'does not replace cached data with api data if request failed and on_api_failure is :warn' do
      subject = described_class.new app_id: 'abc1234', cache_path: json_path, on_api_failure: :warn, max_age: 0
      stub_api(app_id: 'abc1234', source: 'USD', status: 401, body: nil)
      subject.load
      expect(subject.loaded?).to be true
    end
  end

  describe '#load_from_api' do
    it 'loads directly from api if cache_path is nil' do
      subject = described_class.new app_id: 'abc1234'
      expect(subject.loaded?).to be false
      stub_api(app_id: 'abc1234', source: 'USD')
      subject.load_from_api
      expect(subject.loaded?).to be true
    end
    it 'loads saves api data to cache_path then loads from cache path if cache_path is provided' do
      subject = described_class.new app_id: 'abc1234', cache_path: tmp_cache_path
      stub_api(app_id: 'abc1234', source: 'USD', body: json_string)
      expect(subject.loaded?).to be false
      subject.load_from_api
      expect(subject.loaded?).to be true
      json = File.read(tmp_cache_path)
      expect(json).to eq json_string
    end
    it 'raises error on API failure if on_api_failure is not :warn' do
      subject = described_class.new app_id: 'abc1234', cache_path: tmp_cache_path, on_api_failure: :error
      stub_api(app_id: 'abc1234', source: 'USD', status: 401, body: nil)
      expect(subject.loaded?).to be false
      expect {
        subject.load_from_api
      }.to raise_error(OpenURI::HTTPError)
    end
  end

  describe '#stale?' do
    it 'returns false if max_age is nil' do
      expect(subject.stale?).to be false
    end
    it 'returns true if max_age is not nil but last_update_at is nil' do
      subject = described_class.new max_age: 9999999999999999999
      expect(subject.stale?).to be true
    end
    it 'returns true if data is old according to max_age' do
      subject = described_class.new cache_path: json_path, max_age: 0
      subject.load_from_cache_path
      expect(subject.stale?).to be true
    end
    it 'returns false if data is not old according to max_age' do
      subject = described_class.new cache_path: json_path, max_age: 99999999999999999999
      subject.load_from_cache_path
      expect(subject.stale?).to be false
    end
  end

  describe '#load_from_cache_path' do
    it 'loads data from cache_path into rates' do
      subject = described_class.new(cache_path: json_path)
      subject.load_from_cache_path
      expect(subject.last_updated_at).to eq Time.at(1521291605)
      expect(subject.get_rate('USD', 'USD')).to eq 1
      expect(subject.get_rate('USD', 'EUR')).to be_a(BigDecimal)
      expect(subject.get_rate('USD', 'EUR')).to eq BigDecimal.new('0.813255')
    end
  end

  describe '#get_json_from_api' do
    it 'returns json string from api using source and app_id' do
      subject = described_class.new(app_id: 'abc1234', source: 'USD')
      stub_api(app_id: 'abc1234', source: 'USD', body: json_string)
      expect(subject.get_json_from_api).to eq json_string
    end
  end

  describe '#load_json' do
    it 'loads data from json into rates' do
      subject.load_json(json_string)
      expect(subject.last_updated_at).to eq Time.at(1521291605)
      expect(subject.get_rate('USD', 'USD')).to eq 1
      expect(subject.get_rate('USD', 'EUR')).to be_a(BigDecimal)
      expect(subject.get_rate('USD', 'EUR')).to eq BigDecimal.new('0.813255')
    end
  end

  describe '#parse_json' do
    it 'parse given json string' do
      data = subject.parse_json(json_string)
      expect(data['timestamp']).to be_a(Integer)
      expect(data['rates']).to be_a(Hash)
      expect(data['rates']['USD']).to be_a(Numeric)
    end
  end

  private

  def stub_api(app_id:, source: 'USD', body: json_string.gsub('1521291605', Time.now.to_i.to_s), status: 200)
    stub_request(
      :get,
      "https://openexchangerates.org/api/latest.json?app_id=#{app_id}&source=#{source}"
    ).to_return(
      status: status,
      body: body
    )
  end

end
