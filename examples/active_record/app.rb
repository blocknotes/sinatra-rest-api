# require 'pry'

require 'json'
require 'yaml'

require 'sinatra/activerecord'
require 'sinatra/base'

require 'active_record'
require 'sqlite3'

require 'sinatra-rest-api'

# ActiveRecordTest App
module ActiveRecordTest
  env = ENV['RACK_ENV'] || 'development'
  conf = YAML.load( File.read( File.expand_path( '../database.yml', __FILE__ ) ) )
  conf[env]['database'] = File.expand_path( '../' + conf[env]['database'], __FILE__ )

  ActiveRecord::Base.establish_connection( conf[env] )

  # An author
  class Author < ActiveRecord::Base
    has_many :books, dependent: :destroy

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
  end

  # A book
  class Book < ActiveRecord::Base
    belongs_to :author
    belongs_to :category
    has_and_belongs_to_many :tags
    has_many :chapters

    accepts_nested_attributes_for :author
    accepts_nested_attributes_for :category
    accepts_nested_attributes_for :tags

    # default_scope { where( 'id > 2' ) }
    # default_scope { where( published: true ) }

    validates :title, presence: true
  end

  # A category
  class Category < ActiveRecord::Base
    has_many :books
  end

  # A tag
  class Tag < ActiveRecord::Base
    has_and_belongs_to_many :books
  end

  # A chapter
  class Chapter < ActiveRecord::Base
    belongs_to :book

    validates :title, presence: true
  end

  ##############################################################################

  # App main class
  class App < Sinatra::Application
    register Sinatra::RestApi
    register Sinatra::ActiveRecordExtension

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

    configure do
      env = ENV['RACK_ENV'] || 'development'
      conf = YAML.load( File.read( File.expand_path( '../database.yml', __FILE__ ) ) )
      conf[env]['database'] = File.expand_path( '../' + conf[env]['database'], __FILE__ )
      set :database, conf[env]
    end

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
