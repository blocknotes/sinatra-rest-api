# sinatra-rest-api
$LOAD_PATH << File.join(File.dirname(__FILE__))

require 'sinatra/base'

require 'sinatra-rest-api/actions'
require 'sinatra-rest-api/adapter'
require 'sinatra-rest-api/provider'
require 'sinatra-rest-api/router'

# Sinatra namespace
module Sinatra
  # RestApi module definition
  module RestApi
    def resource( klass, options = {}, &block )
      Provider.new( klass, options, self, &block )
    end
  end

  # helpers RestApi
  register RestApi
end
