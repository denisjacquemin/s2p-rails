class RenameEmailsToStudents < ActiveRecord::Migration[5.0]
  def change
    rename_column :students, :emails, :emails_old
  end
end
