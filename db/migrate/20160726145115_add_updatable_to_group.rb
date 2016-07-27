class AddUpdatableToGroup < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :updatable, :boolean, default: true
  end
end
