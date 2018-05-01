class CreateStudentRecipients < ActiveRecord::Migration[5.0]
  def change
    create_table :student_recipients do |t|
      t.integer :student_id
      t.boolean :viewed_by_app, default: false
      t.boolean :viewed_by_email, default: false
      t.boolean :viewed_by_sms, default: false
      t.integer :message_id
      t.integer :school_id

      t.timestamps
    end
  end
end
