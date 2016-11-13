# coding: utf-8
lib = File.expand_path( '../lib', __FILE__ )
$LOAD_PATH.unshift( lib ) unless $LOAD_PATH.include?( lib )

Gem::Specification.new do |s|
  s.name        = 'sinatra-rest-api'
  s.version     = '0.1.0'
  s.authors     = [ 'Mattia Roccoberton' ]
  s.email       = 'mat@blocknot.es'
  s.homepage    = 'http://blocknot.es'
  s.summary     = 'Sinatra REST API generator'
  s.description = 'Sinatra REST API generator: CRUD actions, nested resources, supports ActiveRecord, Sequel and Mongoid'
  s.platform    = Gem::Platform::RUBY
  s.license     = 'ISC'
  s.files       = Dir[ 'lib/**/*.rb' ]

  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency( 'sinatra', '1.4.7' )
end
