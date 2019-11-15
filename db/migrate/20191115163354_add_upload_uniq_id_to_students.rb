class AddUploadUniqIdToStudents < ActiveRecord::Migration[5.2]
  def change
    add_column :students, :upload_uniq_id, :string
  end
end
