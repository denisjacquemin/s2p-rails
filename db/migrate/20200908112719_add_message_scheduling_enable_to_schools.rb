class AddMessageSchedulingEnableToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :message_scheduling_enable, :boolean, default: false
  end
end
