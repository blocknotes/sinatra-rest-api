
ENV['RACK_ENV'] ||= 'test'

# App path
APP_AR = File.expand_path( '../../examples/active_record', __FILE__ ).freeze

require File.join( APP_AR, 'app.rb' )
require File.expand_path( '../spec_helper.rb', __FILE__ )

# AR tests
module ActiveRecordTest
  $VERBOSE = false

  models = {
    author: Author,
    book: Book,
    category: Category,
    chapter: Chapter,
    tag: Tag
  }

  load File.join( APP_AR, 'Rakefile' )
  ActiveRecord::Tasks::DatabaseTasks.db_dir = File.join( APP_AR, 'db' )
  ActiveRecord::Tasks::DatabaseTasks.migrations_paths = File.join( APP_AR, 'db', 'migrate' )

  describe 'ActiveRecord Test App' do
    def app
      App
    end

    before( :all ) do
      # $VERBOSE = false
      # Rake::Task.define_task( :environment )
      Rake::Task['db:environment:set'].invoke
      Rake::Task['db:drop'].invoke
      Rake::Task['db:create'].invoke
      Rake::Task['db:migrate'].invoke
      # $VERBOSE = true
    end

    it 'should list routes in home page' do
      get '/'
      expect( last_response ).to be_ok
      expect( JSON.parse( last_response.body ).count ).to be > 0
    end

    include_examples 'Action: create', models
    include_examples 'Action: read', models
    include_examples 'Action: update', models
    include_examples 'Action: delete', models
    include_examples 'Action: list', models
  end
end
