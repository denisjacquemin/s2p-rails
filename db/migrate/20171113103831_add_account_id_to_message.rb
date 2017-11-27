class AddAccountIdToMessage < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :account_id, :integer
  end
end
