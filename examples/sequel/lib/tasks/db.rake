# require File.expand_path( '../../../app.rb', __FILE__ )
require 'fileutils'
require 'sequel'
require 'yaml'

Sequel.extension :migration

PATH_MIGRATIONS = File.expand_path( '../../../db/migrate', __FILE__ ).freeze unless defined? PATH_MIGRATIONS

def get_db( connect = true )
  env = ENV['RACK_ENV'] || 'development'
  conf = YAML.load( File.read( File.expand_path( '../../../database.yml', __FILE__ ) ) )
  conf[env]['database'] = File.expand_path( '../../../' + conf[env]['database'], __FILE__ )
  connect ? Sequel.connect( conf[env] ) : conf
end

namespace :db do
  desc 'Create database'
  task :create do |_t, _args|
    puts 'Create DB' # unless ENV['RACK_ENV'] == 'test'
    env = ENV['RACK_ENV'] || 'development'
    conf = get_db( false )
    FileUtils.touch conf[env]['database']
  end

  # Ex. rake db:migrate[5]
  desc 'Run migrations'
  task :migrate, [ :version ] do |_t, args|
    # db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    if args[:version]
      puts "Migrating to version #{args[:version]}" # unless ENV['RACK_ENV'] == 'test'
      Sequel::Migrator.run( get_db, PATH_MIGRATIONS, target: args[:version].to_i)
    else
      puts 'Migrating to latest' # unless ENV['RACK_ENV'] == 'test'
      Sequel::Migrator.run( get_db, PATH_MIGRATIONS )
    end
  end

  desc 'Reset database'
  task :reset do |_t, _args|
    puts 'Reset DB' # unless ENV['RACK_ENV'] == 'test'
    Sequel::Migrator.run( get_db, PATH_MIGRATIONS, target: 0 )
  end
end
