$VERBOSE = false

# require 'pry'

# Tests actions
module ActionTests
  RSpec.shared_examples 'Action: delete' do |models|
    context 'Deleting authors...' do
      # path = '/authors'
      path = '/writers' # renamed resource

      # action: delete
      it 'should remove an author' do
        cnt = models[:author].count
        delete path + '/' + models[:author].last.id.to_s
        expect( last_response.status ).to eq( 200 )
        get path
        expect( last_response.status ).to eq( 200 )
        expect( JSON.parse( last_response.body ).length ).to eq( cnt - 1 )
      end

      it 'should not remove an author with invalid id' do
        cnt = models[:author].count
        delete path + '/999'
        expect( last_response.status ).to eq( 404 )
        get path
        expect( last_response.status ).to eq( 200 )
        expect( JSON.parse( last_response.body ).length ).to eq( cnt )
      end
    end
  end
end
