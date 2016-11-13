# Books
class CreateBooks < ActiveRecord::Migration[4.2]
  def change
    create_table :books do |t|
      t.string :title, null: false
      t.text :description
      t.integer :pages
      t.float :price
      t.datetime :dt
      t.integer :author_id
      t.integer :category_id
    end
  end
end
