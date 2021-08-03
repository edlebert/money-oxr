# Change Log
All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

[How to use a CHANGELOG](http://keepachangelog.com/)

## [0.4.3]
- Replace `open` with `URI.open` for compatibility with ruby 3.

## [0.4.2]
- Update to Money 6.13.5
- Fix bugs related to webmock in specs.

## [0.4.1]
- Fix ruby 2.7 warnings.

## [0.4.0] - 2018-11-29
- Use `base` instead of `source` for base currency.
- Use Time.now as last_updated_at timestamp when fetching data over the API

## [0.3.0] - 2018-03-21
### Changed
- Return nil in RateStore if rate is unknown.
- Updated Money dependency to ~> 6.6

## [0.2.0] - 2018-03-19
### Added
- Added safe handling of API request errors.


## [0.1.0] - 2018-03-19
### Changed
- Initial release
