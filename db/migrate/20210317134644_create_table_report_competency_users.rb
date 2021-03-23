class CreateTableReportCompetencyUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :report_competency_users do |t|
      t.integer :user_id
      t.integer :competency_id
      t.boolean :allowed, default: false
    end
  end
end
