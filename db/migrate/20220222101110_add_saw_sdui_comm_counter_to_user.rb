class AddSawSduiCommCounterToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :saw_sdui_comm_counter, :integer, default: 0
  end
end
