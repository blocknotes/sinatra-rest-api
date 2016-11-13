require 'pry'

require 'sinatra/base'
require 'slim'
require 'activeresource'

# Active Resource Test client
module ActiveResourceTest
  # Handle JSON response
  class JsonFormatter
    include ActiveResource::Formats::JsonFormat

    attr_reader :collection_name

    def initialize(collection_name)
      @collection_name = collection_name.to_s
    end

    def decode(json)
      remove_root(ActiveSupport::JSON.decode(json))
    end

    private

    def remove_root(data)
      if data.is_a?(Hash) && data[collection_name]
        data[collection_name]
      else
        data
      end
    end
  end

  # Base class
  class Base < ActiveResource::Base
    self.site = 'http://localhost:3000'
    self.include_root_in_json = true
    self.format = JsonFormatter.new( :collection_name )
  end

  # Author class
  class Writer < Base
    # self.element_name = 'writer'
  end

  # Book class
  class Book < Base; end

  # Category class
  class Category < Base; end

  # Chapter class
  class Chapter < Base; end

  # Tag class
  class Tag < Base; end

  # Main class
  class App < Sinatra::Application
    configure do
      set :port, 4000
      set :views, settings.root
    end

    before do
      @models ||= { writers: Writer, books: Book, categories: Category, chapters: Chapter, tags: Tag }
      @links ||= [
        [ '/', 'Main' ],
        [ '/writers', 'Authors' ],
        [ '/books', 'Books' ],
        [ '/categories', 'Categories' ],
        [ '/chapters', 'Chapters' ],
        [ '/tags', 'Tags' ]
      ]
    end

    get '/' do
      @details = OpenStruct.new( attributes: {} )
      slim 'h2 Main', layout: :layout
    end

    # List
    get '/:model' do
      mod = @models[params[:model].to_sym]
      @model = mod.to_s.split( '::' ).last.gsub( /([A-Z]+)([A-Z][a-z])/, '\1_\2' ).gsub( /([a-z\d])([A-Z])/, '\1_\2' ).tr( '-', '_' ).downcase
      @list = mod.all
      slim "h2 #{params[:model]}", layout: :layout
    end

    # Create
    post '/:model' do
      mod = @models[params[:model].to_sym]
      @model = mod.to_s.split( '::' ).last.gsub( /([A-Z]+)([A-Z][a-z])/, '\1_\2' ).gsub( /([a-z\d])([A-Z])/, '\1_\2' ).tr( '-', '_' ).downcase
      mod.new( @model => params[@model] ).save
      redirect to "/#{params[:model]}"
    end

    # Read
    get '/:model/:id' do
      mod = @models[params[:model].to_sym]
      @details = mod.find( params[:id] )
      @model = mod.to_s.split( '::' ).last.gsub( /([A-Z]+)([A-Z][a-z])/, '\1_\2' ).gsub( /([a-z\d])([A-Z])/, '\1_\2' ).tr( '-', '_' ).downcase
      slim "h2 #{params[:model]}", layout: :layout
    end

    # Update
    post '/:model/:id' do
      mod = @models[params[:model].to_sym]
      @details = mod.find( params[:id] )
      @model = mod.to_s.split( '::' ).last.gsub( /([A-Z]+)([A-Z][a-z])/, '\1_\2' ).gsub( /([a-z\d])([A-Z])/, '\1_\2' ).tr( '-', '_' ).downcase
      params[@model].each { |k, v| @details.send( "#{k}=", v ) }
      @details.save
      redirect to "/#{params[:model]}"
    end

    # Delete
    get '/:model/:id/delete' do
      @item = @models[params[:model].to_sym].find( params[:id] )
      @item.destroy
      redirect to "/#{params[:model]}"
    end

    run! if app_file == $PROGRAM_NAME # = $0 ## starts the server if executed directly by ruby
  end
end
