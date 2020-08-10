class AddAutoDeleteToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :auto_delete, :boolean, default: true
  end
end
