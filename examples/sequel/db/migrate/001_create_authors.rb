Sequel.migration do
  up do
    create_table( :authors ) do
      primary_key :id
      String :name, null: false
      String :email, null: false
      Timestamp :created_at
      Timestamp :updated_at
    end
  end

  down do
    drop_table( :authors )
  end
end
