# MoneyOXR

A [Money](https://github.com/RubyMoney/money)-compatible rate store that uses exchange rates from openexchangerates.org.

A few improvements over the existing [money-open-exchange-rates](https://github.com/spk/money-open-exchange-rates) gem:

* Uses BigDecimal instead of Float for exchange rates.
* Automatically caches API results to file if a :cache_path option is provided.
* Automatically fetches new data from API if data becomes stale if a :max_age option is provided.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'money-oxr'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install money-oxr

## Usage

With the gem, you do not need to manually add exchange rates. Calling load will
load the rates from the cache file or download the rates from the API depending
on your options.  The :source option defaults to

``` ruby
require 'money_oxr/bank'
oxr_bank = MoneyOXR::Bank.new(
  app_id: 'abcd1234',
  cache_path: 'tmp/oxr.json',
  max_age: 86400
)
oxr_bank.store.load
Money.default_bank = oxr_bank
```

If you only want to load data from a file without ever fetching from the API,
the :app_id and :max_age options are not necessary.

``` ruby
require 'money_oxr/bank'
oxr_bank = MoneyOXR::Bank.new(
  cache_path: 'config/oxr.json'
)
oxr_bank.store.load
Money.default_bank = oxr_bank
```

If you are on a paid plan from openexchangerates.org and you wish to use a different
source currency, you may provide it with the :source option.

``` ruby
require 'money_oxr/bank'
oxr_bank = MoneyOXR::Bank.new(
  app_id: 'abcd1234',
  cache_path: 'tmp/oxr.json',
  max_age: 86400,
  source: 'GBP'
)
oxr_bank.store.load
Money.default_bank = oxr_bank
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/edlebert/money-oxr.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
