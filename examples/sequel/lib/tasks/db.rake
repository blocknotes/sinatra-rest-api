require File.expand_path( '../../../app.rb', __FILE__ )
require 'sequel'
require 'fileutils'

Sequel.extension :migration

PATH_MIGRATIONS = File.expand_path( '../../../db/migrate', __FILE__ ).freeze unless defined? PATH_MIGRATIONS

namespace :db do
  desc 'Create database'
  task :create do |_t, _args|
    puts 'Create DB' # unless ENV['RACK_ENV'] == 'test'
    env = ENV['RACK_ENV'] || 'development'
    FileUtils.touch SequelTest::CONF[env]['database']
  end

  # Ex. rake db:migrate[5]
  desc 'Run migrations'
  task :migrate, [ :version ] do |_t, args|
    # db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    if args[:version]
      puts "Migrating to version #{args[:version]}" # unless ENV['RACK_ENV'] == 'test'
      Sequel::Migrator.run( SequelTest::DB, PATH_MIGRATIONS, target: args[:version].to_i)
    else
      puts 'Migrating to latest' # unless ENV['RACK_ENV'] == 'test'
      Sequel::Migrator.run( SequelTest::DB, PATH_MIGRATIONS )
    end
  end

  desc 'Reset database'
  task :reset do |_t, _args|
    puts 'Reset DB' # unless ENV['RACK_ENV'] == 'test'
    Sequel::Migrator.run( SequelTest::DB, PATH_MIGRATIONS, target: 0 )
  end
end
