Sequel.migration do
  up do
    create_table( :categories ) do
      primary_key :id
      String :name, null: false
      Timestamp :created_at
      Timestamp :updated_at
    end
  end

  down do
    drop_table( :categories )
  end
end
