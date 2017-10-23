# -*- encoding: utf-8 -*-
require File.expand_path("../lib/promkiq/version", __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "promkiq"
  gem.version       = Promkiq::VERSION
  gem.authors       = ["Dylan Clendenin"]
  gem.email         = ["dylan@betterdoctor.com"]
  gem.description   = "Sidekiq middleware for collecting Prometheus metrics"
  gem.summary       = "Sidekiq middleware for collecting Prometheus metrics"
  gem.homepage      = "https://github.com/betterdoctor/promkiq"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(spec)/})
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.2.7'

  gem.add_dependency("prometheus-client", "0.7.1")
end
