Sequel.migration do
  up do
    create_table( :categories ) do
      primary_key :id
      String :name, null: false
    end
  end

  down do
    drop_table( :categories )
  end
end
