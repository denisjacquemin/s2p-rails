class AddDeletedToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :deleted, :boolean, default: false
  end
end
