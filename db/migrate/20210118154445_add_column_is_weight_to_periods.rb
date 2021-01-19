class AddColumnIsWeightToPeriods < ActiveRecord::Migration[5.2]
  def change
    add_column :periods, :is_weight, :boolean, default: false
  end
end
