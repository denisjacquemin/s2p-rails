class AddStudentsToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :students, :integer, default: [], array: true
  end
end
