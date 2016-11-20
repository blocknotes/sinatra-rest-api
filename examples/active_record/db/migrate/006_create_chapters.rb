# Authors
class CreateChapters < ActiveRecord::Migration[4.2]
  def change
    create_table :chapters do |t|
      t.string :title, null: false
      t.integer :page
      t.integer :book_id
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
