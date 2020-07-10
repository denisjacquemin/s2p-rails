class AddAllGroupsToPeriods < ActiveRecord::Migration[5.2]
  def change
    add_column :periods, :all_groups, :boolean, default: true
  end
end
