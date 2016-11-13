ENV['RACK_ENV'] ||= 'test'

# App path
APP_MONGO = File.expand_path( '../../examples/mongoid', __FILE__ ).freeze

require File.join( APP_MONGO, 'app.rb' )
require File.expand_path( '../spec_helper.rb', __FILE__ )

# Mongo tests
module MongoidTest
  $VERBOSE = false

  models = {
    author: Author,
    book: Book,
    category: Category,
    chapter: Chapter,
    tag: Tag
  }

  load File.join( APP_MONGO, 'lib', 'tasks', 'db.rake' )

  describe 'Mongoid Test App' do
    def app
      App
    end

    before( :all ) do
      $VERBOSE = false
      Rake::Task.define_task( :environment )
      Rake::Task['db:drop'].invoke
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
