class CreateJoinTableMessagesMessageCategory < ActiveRecord::Migration[5.0]
  def change
    create_join_table :messages, :message_categories do |t|
      # t.index [:message_id, :message_category_id]
      # t.index [:message_category_id, :message_id]
    end
  end
end
