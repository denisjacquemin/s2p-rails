class AddInternalIdToGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :internal_id, :string
  end
end
