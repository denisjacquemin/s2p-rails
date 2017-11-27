class CreateBilledStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :billed_students do |t|
      t.integer :student_id
      t.integer :message_id
      t.string :communication
      t.string :comment
      t.integer :amount_to_pay_cents, default: 0
      t.string :amount_to_pay_currency

      t.timestamps
    end
  end
end
