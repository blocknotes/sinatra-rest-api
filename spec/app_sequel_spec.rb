
ENV['RACK_ENV'] ||= 'test'
ENV['SEQUEL_RECREATE_DB'] = '1'

APP_SEQUEL = File.expand_path( '../../examples/sequel', __FILE__ ).freeze

require File.join( APP_SEQUEL, 'app.rb' )
require File.expand_path( '../spec_helper.rb', __FILE__ )

# Sequel tests
module SequelTest
  models = {
    author: Author,
    book: Book,
    category: Category,
    chapter: Chapter,
    tag: Tag
  }

  load File.join( APP_SEQUEL, 'lib', 'tasks', 'db.rake' )

  describe 'Sequel Test App' do
    def app
      App
    end

    before( :all ) do
      $VERBOSE = false
      # DB clean is done in the test app
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
