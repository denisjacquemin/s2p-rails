class CreateMessageCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :message_categories do |t|
      t.integer :school_id
      t.string :name

      t.timestamps
    end
  end
end
