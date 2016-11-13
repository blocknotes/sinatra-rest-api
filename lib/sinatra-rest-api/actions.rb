module Sinatra
  module RestApi
    # Action
    class Actions
      DONE = { message: :ok }.freeze
      # REF: https://en.wikipedia.org/wiki/Representational_state_transfer#Relationship_between_URL_and_HTTP_methods
      SCHEMA = {
        # Member actions
        # list:     { verb: :get,    path: '/?:format?', fields: [ :id, :title, :author_id, :category_id ] },
        read:     { verb: :get,    path: '/:id.?:format?' },
        update:   { verb: :put,    path: '/:id.?:format?' },
        delete:   { verb: :delete, path: '/:id.?:format?' },
        # Collection actions
        list:     { verb: :get,    path: '/?.?:format?' },
        replace:  { verb: :put,    path: '/?.?:format?' },
        create:   { verb: :post,   path: '/?.?:format?' },
        truncate: { verb: :delete, path: '/?.?:format?' },
        # Member actions
        # update: { verb: [ :post, :put ], path: '/:id.?:format?' },
      }.freeze

      def self.create( route_args, params, mapping )
        unless route_args[:request].form_data?
          route_args[:request].body.rewind
          params.merge!( Provider.settings[:request_type].eql?( :json ) ? JSON.parse( route_args[:request].body.read ) : route_args[:request].body.read )
        end
        params[:_data] = {}
        resource = route_args[:resource]
        if !params[resource].nil? && params[resource].is_a?( Hash )
          cols = mapping[:columns].call( nil ) + mapping[:relations].call( nil ).map { |rel| "#{rel}_attributes" } + mapping[:extra_fields].call( nil )
          cols.delete( 'id' ) # TODO: option to set id field name
          params[:_data] = params[resource].select { |key, _valye| cols.include? key }
          # params[:_data] = params[resource]
          params.delete( resource )
        end
        result = mapping[:create].call( params )
        # route_args[:response].headers['Location'] = '/' # TODO: todo
        [ 201, result.to_json ]
      end

      def self.delete( _route_args, params, mapping )
        mapping[:delete].call( params )
        [ 200, DONE.to_json ]
      end

      def self.list( route_args, params, mapping )
        # TODO: option to enable X-Total-Count ?
        params[:_where] = params[:_where].nil? ? '1=1' : JSON.parse( params[:_where] )
        # params[:_where] = '1=1' unless params[:_where].present?
        route_args[:response].headers['X-Total-Count'] = mapping[:count].call( params ).to_s
        result = mapping[:list].call( params, route_args[:fields] )
        [ 200, result.to_json( include: mapping[:relations].call( nil ) ) ]
      end

      def self.other( _route_args, params, mapping )
        action = params[:_action]
        raise( APIError, 'Action not implemented' ) if mapping[action].nil?
        ret = mapping[action].call( params )
        [ 200, ret.nil? ? DONE.to_json : ret.to_json ]
      end

      def self.read( _route_args, params, mapping )
        result = mapping[:read].call( params )
        [ 200, result.to_json( include: mapping[:relations].call( nil ) ) ]
      end

      def self.update( route_args, params, mapping )
        unless route_args[:request].form_data?
          route_args[:request].body.rewind
          params.merge!( Provider.settings[:request_type].eql?( :json ) ? JSON.parse( route_args[:request].body.read ) : route_args[:request].body.read )
        end
        params[:_data] = {}
        resource = route_args[:resource]
        if !params[resource].nil? && params[resource].is_a?( Hash )
          # params[resource].delete( 'id' ) # TODO: option to set id field name
          # params[:_data] = OpenStruct.new( params[resource] )
          cols = mapping[:columns].call( nil ) + mapping[:relations].call( nil ).map { |rel| "#{rel}_attributes" } + mapping[:extra_fields].call( nil )
          # TODO: consider relations _ids
          cols.delete( 'id' ) # TODO: option to set id field name
          params[:_data] = params[resource].select { |key, _valye| cols.include? key }
          params.delete( resource )
        end
        mapping[:update].call( params )
        [ 200, DONE.to_json ]
      end
    end
  end
end
