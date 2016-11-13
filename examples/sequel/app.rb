require 'pry'

require 'json'
require 'yaml'

require 'sinatra/base'

require 'sequel'
require 'sqlite3'

require 'sinatra-rest-api'

# SequelTest App
module SequelTest
  env = ENV['RACK_ENV'] || 'development'
  CONF = YAML.load( File.read( File.expand_path( '../database.yml', __FILE__ ) ) )
  CONF[env]['database'] = File.expand_path( '../' + CONF[env]['database'], __FILE__ )
  DB = Sequel.connect( CONF[env] )

  unless ENV['SEQUEL_RECREATE_DB'].nil?
    require 'rake'
    FileUtils.rm CONF[env]['database'], force: true
    FileUtils.touch CONF[env]['database']
    load File.join( File.expand_path( '../lib', __FILE__ ), 'tasks', 'db.rake' )
    Rake::Task['db:migrate'].invoke
  end

  Sequel::Model.plugin :json_serializer
  Sequel::Model.plugin :nested_attributes
  Sequel::Model.plugin :validation_helpers

  # An author
  class Author < Sequel::Model
    one_to_many :books

    def validate
      super
      validates_presence [ :name, :email ]
      validates_unique :email
    end
  end

  # A book
  class Book < Sequel::Model
    many_to_one :author
    many_to_one :category
    many_to_many :tags
    one_to_many :chapters

    nested_attributes :author
    nested_attributes :category # , unmatched_pk: :create
    nested_attributes :tags # , unmatched_pk: :create
    nested_attributes :chapters

    def validate
      super
      validates_presence :title
    end
  end

  # A category
  class Category < Sequel::Model
    one_to_many :books
  end

  # A tag
  class Tag < Sequel::Model
    many_to_many :books
  end

  # A chapter
  class Chapter < Sequel::Model
    many_to_one :book

    def validate
      super
      validates_presence :title
    end
  end

  ##############################################################################

  # App entry point
  class App < Sinatra::Application
    register Sinatra::RestApi

    # model Author, actions: { list: { verb: :post }, read: { verb: :post } }
    # model Author, actions: { list: true, read: true }

    # set :restapi_request_type, :json

    resource Author, singular: 'writer' # , plural: 'writers'
    resource Book
    resource Category do
      actions [ :list, :read ]
    end
    resource Chapter
    resource Tag # , actions: [ :list, :read ]

    before do
      content_type :json
      headers( 'Access-Control-Allow-Origin' => '*',
               'Access-Control-Allow-Methods' => Sinatra::RestApi::Router::VERBS.join(',').upcase,
               'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept, Authorization, Token',
               'Access-Control-Expose-Headers' => 'X-Total-Count' )
    end

    options '*' do
      response.headers['Access-Control-Allow-Origin'] = '*'
      response.headers['Access-Control-Allow-Methods'] = 'HEAD,GET,PUT,DELETE,OPTIONS'
      response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
      halt 200
    end

    get '/' do
      Sinatra::RestApi::Router.list_routes.to_json
    end

    not_found do
      return if JSON.parse( body[0] ).include?( 'error' ) rescue nil # Error already defined
      [ 404, { message: 'This is not the page you are looking for...' }.to_json ]
    end

    run! if app_file == $PROGRAM_NAME # = $0 ## starts the server if executed directly by ruby
  end
end
