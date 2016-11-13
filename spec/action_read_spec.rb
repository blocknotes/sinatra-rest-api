$VERBOSE = false

# require 'pry'

# Tests actions
module ActionTests
  RSpec.shared_examples 'Action: read' do |models|
    context 'Reading books...' do
      path = '/books'

      # action: read
      it 'should read the first book' do
        get path + '/' + models[:book].first.id.to_s
        expect( last_response.status ).to eq( 200 )
      end

      it 'should read the last book' do
        get path + '/' + models[:book].last.id.to_s
        expect( last_response.status ).to eq( 200 )
      end

      it 'should not read an author with invalid id' do
        get path + '/999'
        expect( last_response.status ).to eq( 404 )
      end
    end
  end
end
