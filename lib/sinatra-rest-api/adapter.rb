require 'pry'

module Sinatra
  module RestApi
    # ORM Mapping
    class Adapter
      TYPES = %w(ActiveRecord Mongoid Sequel).freeze
      NOT_FOUND = [ 'ActiveRecord::RecordNotFound', 'Mongoid::Errors::DocumentNotFound', 'Sequel::NoMatchingRow' ].freeze

      attr_reader :mapping, :model_singular

      def initialize( provider )
        @provider = provider
        @klass = @provider.klass
        parents = @klass.ancestors.map( &:to_s ) # List of super classes
        if parents.include? 'ActiveRecord::Base'
          @type = 'ActiveRecord'
          @mapping = setup_activerecord
        elsif parents.include? 'Mongoid::Document'
          @type = 'Mongoid'
          @mapping = setup_mongoid
        elsif parents.include? 'Sequel::Model'
          @type = 'Sequel'
          @mapping = setup_sequel
        else
          @type = nil
          @mapping = {}
        end
        @model_singular = provider.klass.to_s.split( '::' ).last.gsub( /([A-Z]+)([A-Z][a-z])/, '\1_\2' ).gsub( /([a-z\d])([A-Z])/, '\1_\2' ).tr( '-', '_' ).downcase
      end

      protected

      ## Sample setup method
      # def setup
      #   {
      #     # Collection actions
      #     list: ->( _params ) { '' },
      #     create: ->( _params ) { { id: 0 } },
      #     truncate: ->( _params ) { '' },
      #     # Member actions
      #     read: ->( _params ) { '' },
      #     update: ->( _params ) { '' },
      #     delete: ->( _params ) { '' },
      #     # Other actions
      #     columns: ->( _params ) { [] },
      #     count: ->( _params ) { 0 },
      #     extra_fields: ->( _params ) { [] },
      #     relations: ->( _params ) { [] }
      #   }
      # end

      def setup_activerecord
        {
          # Collection actions
          list: ->( params, fields ) { @klass.select( fields ).where( params[:_where] ).offset( params[:offset].to_i ).limit( params[:limit].nil? ? -1 : params[:limit].to_i ) },
          # replace: { verb: :put,    path: '/?' },
          create: lambda do |params|
            item = @klass.new( params[:_data] )
            item.save!
            { id: item.id }
          end,
          truncate: ->( _params ) { @klass.delete_all },
          # Member actions
          read: ->( params ) { @klass.find( params[:id] ) },
          update: lambda do |params|
            row = @klass.find( params[:id] ) # Same as read
            row.update!( params[:_data] )
          end,
          delete: lambda do |params|
            row = @klass.find( params[:id] ) # Same as read
            row.destroy
          end,
          # Other actions
          columns:   ->( _params ) { @columns ||= @klass.column_names },
          count:     ->(  params ) { @klass.where( params[:_where] ).count },
          extra_fields: lambda do |_params|
            @extra_fields ||= @klass.reflections.map do |_key, value|
              Provider.klasses[value.class_name][:model_singular] + '_ids' if value.class.to_s == 'ActiveRecord::Reflection::HasManyReflection' || value.class.to_s == 'ActiveRecord::Reflection::HasAndBelongsToManyReflection'
            end.compact
          end,
          relations: ->( _params ) { @relations ||= @klass.reflections.keys }
        }
      end

      def setup_mongoid
        {
          # Collection actions
          # list: ->( _params ) { @klass.all },
          list: lambda do |params, fields|
            if fields.nil?
              @klass.all.skip( params[:offset].to_i ).limit( params[:limit].nil? ? 0 : params[:limit].to_i )
            else
              @klass.all.only( fields ).skip( params[:offset].to_i ).limit( params[:limit].nil? ? 0 : params[:limit].to_i )
            end
          end,
          create: lambda do |params|
            row = @klass.create!( params[:_data] )
            { id: row.id }
          end,
          truncate: ->( _params ) { @klass.delete_all },
          # Member actions
          read: ->( params ) { @klass.find( params[:id] ) },
          update: lambda do |params|
            row = @klass.find( params[:id] ) # Same as read
            row.update!( params[:_data] )
          end,
          delete: lambda do |params|
            row = @klass.find( params[:id] ) # Same as read
            row.destroy
          end,
          # Other actions
          columns: ->( _params ) { @columns ||= @klass.attribute_names },
          count: ->( _params ) { @klass.count },
          extra_fields: ->( _params ) { [] },
          relations: ->( _params ) { @relations ||= @klass.relations.keys }
          # params: ->( _params ) { @params ||= @klass.attribute_names },   # TODO: try this way
        }
      end

      def setup_sequel
        {
          # Collection actions
          list: ->( params, fields ) { @klass.select( *fields ).where( params[:_where] ).offset( params[:offset].to_i ).limit( params[:limit].nil? ? nil : params[:limit].to_i ) },
          # create: ->( params ) { @klass.insert( params[:_data] ) },
          create: lambda do |params|
            # Search nested ids
            ids = {}
            params[:_data].keys.reject { |k| !k.end_with?( '_ids' ) }.each do |k|
              nk = k.sub( /_ids$/, '_pks' )
              ids[nk] = params[:_data].delete k
            end
            # Create a new record
            row = @klass.new( params[:_data] )
            row.save
            # Update ids
            row.update( ids ) unless ids.empty?
            { id: row.id }
          end,
          truncate: ->( _params ) { @klass.truncate },
          # Member actions
          read: ->( params ) { @klass.with_pk!( params[:id] ) },
          update: lambda do |params|
            row = @klass.with_pk!( params[:id] ) # Same as read
            # Adjust nested ids
            params[:_data].keys.reject { |k| !k.end_with?( '_ids' ) }.each do |k|
              nk = k.sub( /_ids$/, '_pks' )
              params[:_data][nk] = params[:_data].delete k
            end
            row.update( params[:_data] )
          end,
          delete: lambda do |params|
            row = @klass.with_pk!( params[:id] ) # Same as read
            row.delete
          end,
          # Other actions
          columns:   ->( _params ) { @columns ||= @klass.columns.map( &:to_s ) },
          count:     ->(  params ) { @klass.where( params[:_where] ).count },
          extra_fields: lambda do |_params|
            @extra_fields ||= @klass.association_reflections.map { |_key, value| Provider.klasses[value[:class_name].split( '::' ).last][:model_singular] + '_ids' if value[:type] == :one_to_many || value[:type] == :many_to_many }.compact
          end,
          # extra_fields: ->( _params ) { [] },
          relations: ->( _params ) { @relations ||= @klass.associations }
        }
      end
    end
  end
end
