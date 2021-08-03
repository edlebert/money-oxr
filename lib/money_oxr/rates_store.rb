require 'money/rates_store/memory'
require 'json'
require 'bigdecimal'
require 'open-uri'

module MoneyOXR
  class RatesStore < Money::RatesStore::Memory

    attr_reader :app_id, :source, :cache_path, :last_updated_at, :max_age, :on_api_failure

    def initialize(*)
      super
      @app_id = options[:app_id]
      @source = options[:source] || 'USD'
      @cache_path = options[:cache_path]
      @max_age = options[:max_age]
      @on_api_failure = options[:on_api_failure] || :warn
    end

    def get_rate(iso_from, iso_to)
      load
      super || begin
        if iso_from == source
          nil
        elsif inverse_rate = super(iso_to, iso_from)
          add_rate(iso_from, iso_to, 1 / inverse_rate)
        elsif iso_to == source
          nil
        else
          rate1 = get_rate(iso_from, source)
          rate2 = get_rate(source, iso_to)
          rate1 && rate2 && add_rate(iso_from, iso_to, rate1 * rate2)
        end
      end
    end

    def loaded?
      transaction do
        rates.any?
      end
    end

    def load
      # Loads data and ensures it is not stale.
      if !loaded? && cache_path && File.exist?(cache_path)
        load_from_cache_path
      end
      if app_id && (!loaded? || stale?)
        load_from_api
      end
    end

    def stale?
      return false if !max_age
      return true if last_updated_at.nil?
      last_updated_at + max_age < Time.now
    end

    def load_from_api
      # When loading from the API, set the last_updated_at to now.
      # "timestamp" value in response may be days old (it may not update over
      # the weekend)
      now = Time.now
      json = get_json_from_api
      # Protect against saving or loading nil/bad data from API.
      return unless json && json =~ /rates/
      if cache_path
        write_cache_file(json)
        load_from_cache_path
      else
        load_json(json)
      end
      @last_updated_at = now
    end

    def get_json_from_api
      URI.open(api_uri).read
    rescue OpenURI::HTTPError, SocketError
      raise unless on_api_failure == :warn
      warn "#{$!.class}: #{$!.message}"
      nil
    end

    def api_uri
      "https://openexchangerates.org/api/latest.json?base=#{source}&app_id=#{app_id}"
    end

    def load_from_cache_path
      load_json(File.read(cache_path))
    end

    def write_cache_file(text)
      File.open(cache_path, 'w') { |file| file.write text }
    end

    def load_json(text)
      data = parse_json(text)
      transaction do
        @last_updated_at = Time.at(data['timestamp'])
        rates.clear
        data['rates'].each do |iso_to, rate|
          add_rate(source, iso_to, rate)
        end
      end
    end

    def parse_json(text)
      # Convert text to strings so that we can use BigDecimal instead of Float
      text = text.gsub(/("[A-Z]{3}": ?)(\d+\.\d+)/, '\\1"\\2"')
      data = JSON.parse(text)
      data['rates'] = data['rates'].each_with_object({}) do |(key, value), rates|
        rates[key] = BigDecimal(value)
      end
      data
    end

  end
end
