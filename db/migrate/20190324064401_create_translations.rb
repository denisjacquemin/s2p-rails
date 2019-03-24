class CreateTranslations < ActiveRecord::Migration[5.2]
  def change
    create_table :translations do |t|
      t.integer :message_id
      t.string :title
      t.text :content
      t.string :language_code
      t.integer :school_id

      t.timestamps
    end
  end
end
