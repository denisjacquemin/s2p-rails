class AddActivateMessageDateLimitToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :activate_message_date_limit, :boolean, default: true
  end
end
