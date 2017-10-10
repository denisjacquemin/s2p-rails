class AddStudentsNamesToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :students_names, :string
  end
end
