class AddCodeToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :code, :string
  end
end
