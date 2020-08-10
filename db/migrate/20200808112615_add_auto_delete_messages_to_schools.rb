class AddAutoDeleteMessagesToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :auto_delete_messages, :boolean, default: true
  end
end
