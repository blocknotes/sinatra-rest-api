Sequel.migration do
  up do
    create_table( :chapters ) do
      primary_key :id
      String :title, null: false
      Integer :page
      Integer :book_id, null: false
      Timestamp :created_at
      Timestamp :updated_at
    end
  end

  down do
    drop_table( :chapters )
  end
end
