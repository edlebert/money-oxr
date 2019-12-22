# coding: utf-8

Gem::Specification.new do |spec|
  spec.name          = "money-oxr"
  spec.version       = "0.4.1"
  spec.authors       = ["Ed Lebert"]

  spec.summary       = %q{A Money-compatible rate store that uses exchange rates from openexchangerates.org.}
  spec.homepage      = "https://github.com/edlebert/money-oxr"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end
  spec.require_paths = ["lib"]

  spec.add_dependency "money", ">= 6.13.5"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "webmock"
end
