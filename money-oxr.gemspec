# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "money-oxr"
  spec.version       = "0.2.0"
  spec.authors       = ["Ed Lebert"]

  spec.summary       = %q{A Money-compatible rate store that uses exchange rates from openexchangerates.org.}
  spec.homepage      = "https://github.com/edlebert/money-oxr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "money", "~> 6.6"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "webmock", "~> 3.3"
end
