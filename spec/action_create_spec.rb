$VERBOSE = false

# require 'pry'

# Tests actions
module ActionTests
  RSpec.shared_examples 'Action: create' do |models|
    ##############################################################################

    context 'Creating authors...' do
      # path = '/authors'
      path = '/writers' # renamed resource
      random_authors = []
      (1..( rand( 15 ) + 5 )).each do |_i|
        random_authors.push( name: Faker::Book.author, email: Faker::Internet.email )
      end
      random_authors.uniq! { |a| a[:email] }

      # action: create
      it "should create #{random_authors.length} authors" do
        random_authors.each do |author|
          post path, writer: author
          expect( last_response.status ).to eq( 201 ) # response = created ?
          expect( JSON.parse( last_response.body ).include?( 'id' ) ).to be true # id is returned ?
          expect( models[:author].where( author ).count ).to eq( 1 ) # record exists ?
        end
        expect( models[:author].count ).to eq( random_authors.length ) # check number of authors created
      end

      it 'should not create authors with invalid data' do
        authors = [
          {},
          { name: '', email: ' ' },
          { email: 'aaa@bbb.ccc' },
          { name: '', email: 'aaa@bbb.ccc' },
          { name: '   ', email: 'aaa@bbb.ccc' },
          { name: 'Dick' },
          { name: 'Dick', email: '' },
          { name: 'Dick', email: '  ' }
        ]
        authors.each do |author|
          post path, writer: author
          expect( last_response.status ).to eq( 400 )
        end
      end

      # action: create
      it 'no authors with same email' do
        post path, writer: { name: 'Jane Doe', email: random_authors.sample[:email] }
        expect( last_response.status ).to eq( 400 )
      end
    end

    ##############################################################################

    context 'Creating tags...' do
      random_tags = []
      (1..( rand( 6 ) + 3 ) ).each { |_i| random_tags.push( name: Faker::Hipster.word ) }
      random_tags.uniq! { |t| t[:name] }

      # action: create
      it "should create #{random_tags.length} tags" do
        random_tags.each do |tag|
          post '/tags', tag: tag
          expect( last_response.status ).to eq( 201 )
          expect( JSON.parse( last_response.body ).include?( 'id' ) ).to be true
          expect( models[:tag].where( tag ).count ).to eq( 1 )
        end
        expect( models[:tag].count ).to eq( random_tags.length )
      end
    end

    ##############################################################################

    context 'Creating books...' do
      random_books = []
      (1..( rand( 4 ) + 2 )).each do |_i|
        random_books.push( title: Faker::Book.title )
      end
      random_books.uniq! { |b| b[:title] }
      (1..( rand( 4 ) + 2 )).each do |_i|
        random_books.push( title: Faker::Hipster.sentence, pages: rand( 1000 ), price: rand * 20 )
      end
      new_cats = rand( 4 ) + 2
      (1..new_cats).each do |_i|
        random_books.push( title: Faker::Superhero.name, description: Faker::StarWars.quote, pages: rand( 1000 ), price: rand * 20, category_attributes: { name: Faker::Book.genre } )
      end
      new_tags = 2
      (1..new_tags).each do |_i|
        random_books.push( title: Faker::Superhero.name, description: Faker::StarWars.quote, pages: rand( 1000 ), price: rand * 20, tags_attributes: [ { name: Faker::Hipster.word } ] )
      end

      # action: create
      it "should create #{random_books.length} books, #{new_cats} categories and #{new_tags} tags" do
        tags_ids = models[:tag].all.map( &:id )
        (1..( rand( 4 ) + 2 )).each do |_i|
          random_books.push( title: Faker::University.name, pages: rand( 1000 ), price: rand * 20, tag_ids: tags_ids.sample( rand( 3 ) ) )
        end
        random_books.each do |book|
          book[:author_id] = models[:author].all.sample.id if rand > 0.5
          post '/books', book: book
          expect( last_response.status ).to eq( 201 ) # check if the status is equal to created
          expect( JSON.parse( last_response.body ).include?( 'id' ) ).to be true # check if the id is returned
          category_attributes = book.delete :category_attributes
          tags_attributes = book.delete :tags_attributes
          tag_ids = book.delete :tag_ids
          expect( models[:book].where( book ).count ).to eq( 1 ) # check if book is created
          # check the relations
          row = models[:book].where( book ).first
          expect( row.tags.map( &:id ).sort ).to eq( tag_ids.sort ) unless tag_ids.nil?
          expect( row.tags.map( &:name ) ).to eq( tags_attributes.map { |a| a[:name] } ) unless tags_attributes.nil?
          expect( row.category.name ).to eq( category_attributes[:name] ) unless category_attributes.nil?
        end
        expect( models[:book].count ).to eq( random_books.length )
        expect( models[:category].count ).to eq( new_cats )
        expect( models[:tag].count ).to eq( tags_ids.length + new_tags )
      end
    end

    ##############################################################################

    context 'Creating chapters...' do
      random_chapters = []
      (1..( rand( 10 ) + 2 )).each do |_i|
        random_chapters.push( title: Faker::Superhero.name )
      end
      random_chapters.uniq! { |c| c[:title] }

      # action: create
      it "should create #{random_chapters.length} chapters" do
        ids = models[:book].all.map( &:id )
        random_chapters.each do |chapter|
          chapter[:book_id] = ids.sample
          post '/chapters', chapter: chapter
          expect( last_response.status ).to eq( 201 )
          expect( JSON.parse( last_response.body ).include?( 'id' ) ).to be true
          expect( models[:chapter].where( chapter ).count ).to eq( 1 )
        end
        expect( models[:chapter].count ).to eq( random_chapters.length )
      end

      it 'should not create a chapter without data' do
        chapters = [
          {},
          { title: 'Chapter 3' },
          { book_id: models[:book].last.id.to_s }
        ]
        chapters.each do |chapter|
          post '/chapters', chapter: chapter
          expect( last_response.status ).to eq( 400 )
        end
      end
    end

    ##############################################################################

    context 'Creating categories...' do
      # action: create
      it 'should not create categories' do
        post '/categories', category: { name: 'A cat' }
        expect( last_response.status ).to eq( 404 )
      end
    end
  end
end
