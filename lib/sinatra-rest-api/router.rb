module Sinatra
  module RestApi
    # Router
    class Router
      EXTS = [ 'json' ].freeze # TODO: load valid exts from an option
      VERBS = [ :get, :post, :put, :patch, :delete, :options, :link, :unlink ].freeze

      attr_reader :path_singular, :plural

      @@all_routes = []

      def initialize( provider )
        @provider = provider
        options = @provider.options
        @path_singular = options[:singular].nil? ? provider.adapter.model_singular : options[:singular].downcase
        @plural = options[:plural].nil? ? Router.pluralize( @path_singular ) : options[:plural].downcase
        @routes = {}
        routes = options[:actions].nil? ? Actions::SCHEMA.keys : options[:actions]
        list = routes.delete :list
        if routes.is_a?( Array )
          # Move list action to the end to lower its priority
          routes.push list unless list.nil?
          routes.each { |route| init_route route, Actions::SCHEMA[route] if Actions::SCHEMA.include? route }
        elsif routes.is_a?( Hash )
          routes.each { |route, data| init_route route, data }
          # Process list action in the end
          init_route :list, list unless list.nil?
        end
      end

      def generate_routes
        @routes.each do |route, data|
          path = "/#{@plural}#{data[:path]}"
          if data[:verb].is_a?( Array )
            data[:verb].each do |verb|
              prepare_route( route: route, resource: @path_singular, verb: verb, path: path, fields: data[:fields], mapping: @provider.adapter.mapping )
            end
          else
            prepare_route( route: route, resource: @path_singular, verb: data[:verb], path: path, fields: data[:fields], mapping: @provider.adapter.mapping )
          end
        end
        @routes
      end

      def self.pluralize( string )
        case string
        when /(s|x|z|ch)$/
          "#{string}es"
        when /(a|e|i|o|u)y$/
          "#{string}s"
        when /y$/
          "#{string[0..-2]}ies"
        when /f$/
          "#{string[0..-2]}ves"
        when /fe$/
          "#{string[0..-3]}ves"
        else
          "#{string}s"
        end
      end

      def self.list_routes
        @@all_routes
      end

      def self.on_error( e )
        ret = 500
        if e.class == APIError
          ret = 400 # API error
        elsif Adapter::NOT_FOUND.include? e.class.to_s
          ret = 404 # Item not found
        elsif Adapter::TYPES.include?( e.class.to_s.split( '::' )[0] ) || e.class == JSON::ParserError
          ret = 400 # Invalid request
        else
          raise e
        end
        [ ret, { error: e.class.to_s, message: e.message }.to_json ]
      end

      private

      def init_route( route, data )
        return unless Actions::SCHEMA.include? route # Invalid action
        @routes[route] = Actions::SCHEMA[route] unless data.is_a?( FalseClass )
        return unless data.is_a?( Hash )
        @routes[route][:verb] = data[:verb] unless data[:verb].nil?
        @routes[route][:path] = data[:path] unless data[:path].nil?
      end

      def prepare_route( route_args )
        if VERBS.include? route_args[:verb]
          @@all_routes.push "#{route_args[:verb].upcase}: #{route_args[:path]}"
          @provider.app.send( route_args[:verb], route_args[:path] ) do
            # app = self
            begin
              raise( APIError, 'Invalid request format' ) if !params[:format].nil? && !EXTS.include?( params[:format] )
              route_args[:request] = request
              route_args[:response] = response
              if Actions.respond_to? route_args[:route]
                Actions.send( route_args[:route], route_args, params, route_args[:mapping] )
              else
                params[:_action] = route_args[:route]
                Actions.other( route_args, params, route_args[:mapping] )
              end
            rescue StandardError => e
              Router.on_error e
            end
          end
        else
          # logger.error "Invalid verb: #{verb}"
          puts "Invalid verb: #{verb}" # TODO: use logger
        end
      end
    end
  end
end
