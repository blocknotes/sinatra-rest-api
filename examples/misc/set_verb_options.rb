require 'sinatra/base'

class TestApp < Sinatra::Application
  options '*' do
    response.headers['Access-Control-Allow-Origin'] = '*'
    response.headers['Access-Control-Allow-Methods'] = 'HEAD,GET,PUT,DELETE,OPTIONS'
    response.headers['Access-Control-Allow-Headers'] = 'X-Requested-With, X-HTTP-Method-Override, Content-Type, Cache-Control, Accept'
    halt 200
  end

  run! if app_file == $PROGRAM_NAME # = $0 ## starts the server if executed directly by ruby
end
