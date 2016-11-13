$VERBOSE = false

# require 'pry'

# Tests actions
module ActionTests
  RSpec.shared_examples 'Action: list' do |models|
    context 'Listing books...' do
      cnt = 0

      # action: list
      it 'should list all books' do
        cnt = models[:book].count
        get '/books'
        expect( last_response.status ).to eq( 200 )
        expect( JSON.parse( last_response.body ).length ).to eq( cnt )
      end

      it 'should paginate books' do
        page_size = 2
        limit = cnt - page_size
        get "/books?limit=#{limit}"
        expect( last_response.status ).to eq( 200 )
        expect( JSON.parse( last_response.body ).length ).to eq( limit )
        get "/books?limit=#{limit}&offset=#{limit}"
        expect( last_response.status ).to eq( 200 )
        expect( JSON.parse( last_response.body ).length ).to eq( page_size )
      end
    end
  end
end
