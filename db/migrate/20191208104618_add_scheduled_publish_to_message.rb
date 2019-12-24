class AddScheduledPublishToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :scheduled_publish, :datetime
  end
end
