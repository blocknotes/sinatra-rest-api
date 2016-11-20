# BooksTags
class CreateBooksTags < ActiveRecord::Migration[4.2]
  def change
    create_table :books_tags do |t|
      t.integer :book_id, null: false
      t.integer :tag_id, null: false
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
