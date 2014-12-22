# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'admix/version'

Gem::Specification.new do |spec|
  spec.name          = 'admix'
  spec.version       = Admix::VERSION
  spec.authors       = ['Darren Haken']
  spec.email         = ['darrenhaken@gmail.com']
  spec.summary       = 'Mingle Project Management Report Generator'
  spec.description   = 'Extracts Mingle events and pipes them into Google Spreadsheets so reports can be generated'
  spec.homepage      = 'https://github.com/darrenhaken/admix'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'
end
