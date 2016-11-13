Sequel.migration do
  up do
    create_table( :chapters ) do
      primary_key :id
      String :title, null: false
      Integer :page
      Integer :book_id, null: false
    end
  end

  down do
    drop_table( :chapters )
  end
end
