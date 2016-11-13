Sequel.migration do
  up do
    create_table( :books ) do
      primary_key :id
      String :title, null: false
      String :description, text: true
      Integer :pages
      Float :price
      DateTime :dt
      Integer :author_id
      Integer :category_id
    end
  end

  down do
    drop_table( :books )
  end
end
