class AddOldMessageDateLimit < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :message_day_limit, :integer, default: 30
    add_column :schools, :message_month_limit, :integer, default: 6
  end
end
