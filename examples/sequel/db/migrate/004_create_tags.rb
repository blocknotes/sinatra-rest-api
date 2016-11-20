Sequel.migration do
  up do
    create_table( :tags ) do
      primary_key :id
      String :name, null: false
      Timestamp :created_at
      Timestamp :updated_at
    end
  end

  down do
    drop_table( :tags )
  end
end
