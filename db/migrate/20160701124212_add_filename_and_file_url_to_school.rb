class AddFilenameAndFileUrlToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :filename, :string
    add_column :schools, :file_url, :string
  end
end
