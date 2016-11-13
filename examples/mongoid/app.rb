# require 'pry'

require 'json'
require 'yaml'

require 'sinatra/base'

require 'mongoid'

require 'sinatra-rest-api'

# MongoidTest App
module MongoidTest
  env = ENV['RACK_ENV'] || 'development'

  Mongoid.load!( File.expand_path( '../database.yml', __FILE__ ), env.to_sym )

  # An author
  class Author
    include Mongoid::Document

    field :name, type: String
    field :email, type: String

    has_many :books
    # has_many :books, inverse_of: :author

    validates :name, presence: true
    validates :email, presence: true, uniqueness: true
  end

  # A book
  class Book
    include Mongoid::Document

    # Fields
    field :title, type: String
    field :description, type: String
    field :pages, type: Integer
    field :price, type: Float
    field :dt, type: DateTime

    # Relations
    belongs_to :category, optional: true # optional disables required relations
    belongs_to :author, optional: true
    has_and_belongs_to_many :tags
    has_many :chapters

    accepts_nested_attributes_for :category
    accepts_nested_attributes_for :author
    accepts_nested_attributes_for :tags

    # has_one :author, inverse_of: :books
    # has_one :category, inverse_of: :book

    # embeds_one :author
    # embeds_one :category

    validates :title, presence: true
  end

  # A category
  class Category
    include Mongoid::Document

    field :name, type: String

    has_many :books
    # has_many :books, inverse_of: :category

    # embedded_in :book
  end

  # A tag
  class Tag
    include Mongoid::Document

    field :name, type: String

    has_and_belongs_to_many :books
  end

  # A chapter
  class Chapter
    include Mongoid::Document

    belongs_to :book

    field :title, type: String

    validates :title, presence: true
  end

  ##############################################################################

  # App main class
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
