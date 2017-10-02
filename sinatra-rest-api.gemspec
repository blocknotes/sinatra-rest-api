# coding: utf-8
lib = File.expand_path( '../lib', __FILE__ )
$LOAD_PATH.unshift( lib ) unless $LOAD_PATH.include?( lib )

Gem::Specification.new do |spec|
  spec.name        = 'sinatra-rest-api'
  spec.version     = '0.1.4'
  spec.authors     = [ 'Mattia Roccoberton' ]
  spec.email       = 'mat@blocknot.es'
  spec.homepage    = 'https://github.com/blocknotes/sinatra-rest-api'
  spec.summary     = 'Sinatra REST API generator'
  spec.description = 'Sinatra REST API generator: CRUD actions, nested resources, supports ActiveRecord, Sequel and Mongoid'
  spec.platform    = Gem::Platform::RUBY
  spec.license     = 'ISC'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.0.0'

  spec.add_runtime_dependency 'sinatra', '> 1.4'
end
