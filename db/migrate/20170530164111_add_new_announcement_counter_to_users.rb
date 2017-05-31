class AddNewAnnouncementCounterToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :new_announcement_counter, :integer, default: 0
  end
end
