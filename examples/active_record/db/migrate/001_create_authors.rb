# Authors
class CreateAuthors < ActiveRecord::Migration[4.2]
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
