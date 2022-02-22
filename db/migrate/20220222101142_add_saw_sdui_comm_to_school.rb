class AddSawSduiCommToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :saw_sdui_comm, :boolean, default: false
  end
end
