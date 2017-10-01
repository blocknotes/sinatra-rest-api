module Sinatra
  module RestApi
    # Prodiver
    class Provider
      OPTIONS = [ :actions, :include, :plural, :singular ].freeze
      REQUEST = {
        # content_types: [ :formdata, :json, :multipart, :www_form ]
        content_types: [ :json, :www_form ]
      }.freeze
      RESPONSE = {}.freeze

      attr_reader :adapter, :app, :klass, :options, :router

      @@klasses = {}
      @@settings = {
        request_type: :www_form
      }

      def initialize( klass, opts, app, &block )
        @klass = klass
        @options = opts
        @app = app
        instance_eval( &block ) if block_given?
        init_settings
        @adapter = Adapter.new( self )
        @router = Router.new( self )
        @router.generate_routes
        klass_name = klass.to_s.split( '::' ).last
        @@klasses[klass_name] = { class: klass, model_singular: @adapter.model_singular }
        decorate_model
      end

      def method_missing( name, *args, &block )
        super unless OPTIONS.include? name
        @options[name] = args[0]
      end

      def respond_to_missing?( name, include_all = false )
        super unless OPTIONS.include? name
        true
      end

      def self.klasses
        @@klasses
      end

      def self.settings
        @@settings
      end

      private

      def decorate_model
        # Attach meta data to model
        @klass.class.module_eval { attr_accessor :restapi }
        @klass.restapi = {}
        @klass.restapi[:model_singular] = @adapter.model_singular
        # @klass.restapi[:model_plural] = @router.plural
        @klass.restapi[:path_singular] = @router.path_singular
        @klass.restapi[:path_plural] = @router.plural
        # @klass.restapi_routes = routes
        # @klass.association_reflections[:chapters][:class_name].split( '::' ).last
        # => Chapter
        # @@klasses['Book'][:model_singular]
        # => book
      end

      def init_settings
        @@settings[:request_type] = @app.restapi_request_type if defined?( @app.restapi_request_type ) && REQUEST[:content_types].include?( @app.restapi_request_type )
      end
    end

    # API Exception class
    class APIError < StandardError
    end
  end
end
