class AddFormDueDateToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :form_due_date, :datetime
  end
end
