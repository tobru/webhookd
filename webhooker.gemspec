# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'webhooker/version'

Gem::Specification.new do |spec|
  spec.name               = "webhooker"
  spec.version            = Webhooker::VERSION
  spec.authors            = ["Tobias Brunner"]
  spec.email              = ["tobias@tobru.ch"]
  spec.summary            = %q{A configurable webhook receiver}
  spec.description        = %q{Can receive webhooks from different sources and take actions}
  spec.homepage           = "https://tobrunet.ch"
  spec.license            = "MIT"

  spec.files              = `git ls-files -z`.split("\x0")
  spec.executables        = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.default_executable = "webhooker"
  spec.test_files         = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths      = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"

  spec.add_runtime_dependency 'sinatra'

end
