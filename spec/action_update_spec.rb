$VERBOSE = false

# require 'pry'

# Tests actions
module ActionTests
  RSpec.shared_examples 'Action: update' do |models|
    context 'Updating authors...' do
      # path = '/authors'
      path = '/writers' # renamed resource

      # action: update
      it 'should update some authors' do
        random_authors = []
        (1..(models[:author].count / 2 )).each do |_i|
          random_authors.push( name: Faker::Book.author, email: Faker::Internet.email )
        end
        random_authors.uniq! { |a| a[:email] }
        ids = models[:author].all.sample( random_authors.length ).map( &:id )
        random_authors.each_with_index do |author, index|
          put path + '/' + ids[index].to_s, writer: author
          expect( last_response.status ).to eq( 200 ) # status = ok ?
          expect( JSON.parse( last_response.body )['message'] ).to eq 'ok' # message = ok ?
          row = models[:author].where( author )
          expect( row.count ).to eq 1 # record exists ?
          expect( row.first.id ).to eq ids[index] # record corresponds ?
        end
      end

      it 'should not update an author with invalid data' do
        id = models[:author].all.sample.id
        authors = [
          { name: '' },
          { email: '' },
          { name: '', email: '' },
          { name: ' ', email: '   ' }
        ]
        authors.each do |author|
          put path + '/' + id.to_s, writer: author
          expect( last_response.status ).to eq( 400 )
        end
      end
    end

    ##############################################################################

    context 'Updating books...' do
      # action: update
      it 'should update some books' do
        cnt = ( models[:book].count - 1 ) / 4
        random_books = []
        (1..cnt).each do |_i|
          random_books.push( title: Faker::Book.title + " [#{rand( 8 ) + 1}]" )
        end
        random_books.uniq! { |b| b[:title] }
        (1..cnt).each do |_i|
          random_books.push( title: Faker::Hipster.sentence, pages: rand( 1000 ), price: rand * 20 )
        end
        (1..cnt).each do |_i|
          random_books.push( title: Faker::StarWars.quote, pages: rand( 1000 ), price: rand * 20, category_attributes: { name: Faker::Book.genre } )
        end
        tags_ids = models[:tag].all.map( &:id )
        (1..cnt).each do |_i|
          random_books.push( title: Faker::University.name, pages: rand( 1000 ), price: rand * 20, category_id: models[:category].all.sample.id, tag_ids: tags_ids.sample( rand( 3 ) ) )
        end
        ids = models[:book].all.sample( random_books.length ).map( &:id )
        random_books.each_with_index do |book, index|
          put '/books/' + ids[index].to_s, book: book
          expect( last_response.status ).to eq( 200 ) # check if the status is equal to ok
          category_attributes = book.delete :category_attributes
          tags_attributes = book.delete :tags_attributes
          tag_ids = book.delete :tag_ids
          expect( models[:book].where( book ).count ).to eq( 1 ) # check if book is created
          # check the relations
          row = models[:book].where( id: ids[index] ).first
          expect( row.tags.map( &:id ).sort ).to eq( tag_ids.sort ) if !tag_ids.nil? && tag_ids.any?
          expect( row.tags.map( &:name ) ).to eq( tags_attributes.map { |a| a[:name] } ) unless tags_attributes.nil?
          expect( row.category.name ).to eq( category_attributes[:name] ) unless category_attributes.nil?
        end
      end

      it 'should not update a book without title' do
        put '/books/' + models[:book].all.sample.id.to_s, book: { title: '', pages: rand( 1000 ), price: rand * 20 }
        expect( last_response.status ).to eq( 400 )
      end
    end

    ##############################################################################

    context 'Updating categories...' do
      # action: update
      it 'should not update categories' do
        put '/categories/' + models[:category].all.sample.id.to_s, category: { name: 'A cat' }
        expect( last_response.status ).to eq( 404 )
      end
    end
  end
end
