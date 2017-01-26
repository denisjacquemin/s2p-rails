class ChangeUuidNameToMessages < ActiveRecord::Migration[5.0]
  def change
    rename_column :messages, :uuid, :muuid
  end
end
