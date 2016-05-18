# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ares/version'

Gem::Specification.new do |spec|
  spec.name          = 'ares.rb'
  spec.version       = Ares::VERSION
  spec.authors       = ['Ondřej Svoboda','Bohuslav Blin']
  spec.email         = ['blin@uol.cz']

  spec.summary       = 'ARES library'
  spec.description   = 'Gem for accesing business information from ARES database.'
  spec.homepage      = "http://www.uol.cz"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_dependency 'ico-validator', '~> 0.4'

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 11.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'rails'

  spec.add_runtime_dependency 'httparty'
  spec.add_runtime_dependency 'nokogiri'
end
