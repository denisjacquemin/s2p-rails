class CreateTableReportGroupUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :report_group_users do |t|
      t.integer :user_id
      t.integer :group_id
      t.boolean :allowed, default: false
    end
  end
end
