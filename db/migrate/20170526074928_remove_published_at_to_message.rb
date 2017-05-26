class RemovePublishedAtToMessage < ActiveRecord::Migration[5.0]
  def change
    remove_column :messages, :publish_date
  end
end
