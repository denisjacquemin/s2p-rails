class AddTypeAndWhenToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :when, :string
    add_column :messages, :mtype, :integer
  end
end
