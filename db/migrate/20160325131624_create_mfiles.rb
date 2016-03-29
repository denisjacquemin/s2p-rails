class CreateMfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :mfiles do |t|
      t.string :filename
      t.string :file_url
      t.integer :school_id
      t.integer :message_id

      t.timestamps
    end
  end
end
