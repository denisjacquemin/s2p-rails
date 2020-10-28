class AddAfterUpdateActionToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :after_update_action, :string
  end
end
