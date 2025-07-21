class CreateImages < ActiveRecord::Migration[8.0]
  def change
    create_table :images do |t|
      t.string :name
      t.text :description
      t.string :status, default: "ready"

      t.timestamps
    end
  end
end
