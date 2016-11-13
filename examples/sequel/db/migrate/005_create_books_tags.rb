Sequel.migration do
  up do
    create_table( :books_tags ) do
      primary_key :id
      Integer :book_id, null: false
      Integer :tag_id, null: false
    end
  end

  down do
    drop_table( :books_tags )
  end
end
