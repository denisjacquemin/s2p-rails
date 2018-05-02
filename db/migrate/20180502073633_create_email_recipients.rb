class CreateEmailRecipients < ActiveRecord::Migration[5.0]
  def change
    create_table :email_recipients do |t|
      t.string :email
      t.integer :student_id
      t.integer :message_id
      t.string :status
      t.string :dateandtime

      t.timestamps
    end
  end
end
