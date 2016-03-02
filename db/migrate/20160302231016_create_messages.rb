class CreateMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :messages do |t|
      t.string :title
      t.text :content
      t.integer :school_id
      t.integer :groups, array: true, default: []

      t.timestamps
    end
  end
end
