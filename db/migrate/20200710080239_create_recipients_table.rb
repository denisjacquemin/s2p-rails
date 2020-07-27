class CreateRecipientsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :recipients do |t|
      t.integer :message_id
      t.integer :student_id
      t.integer :school_id
      t.string :code
      t.boolean :viewed_by_email
      t.boolean :viewed_by_app
      t.boolean :viewed_by_sms
      t.timestamps
    end
    add_index :recipients, :code
  end
end
