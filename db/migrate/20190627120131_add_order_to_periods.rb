class AddOrderToPeriods < ActiveRecord::Migration[5.2]
  def change
    add_column :periods, :order, :integer
  end
end
