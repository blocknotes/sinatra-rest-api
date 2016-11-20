# Tags
class CreateTags < ActiveRecord::Migration[4.2]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.timestamp :created_at
      t.timestamp :updated_at
    end
  end
end
