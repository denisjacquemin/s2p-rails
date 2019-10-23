class AddUploadIdToGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :upload_id, :string
  end
end
