class CreateCompetencyGroupUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :competency_group_users do |t|
      t.integer :competency_group_id
      t.integer :user_id

      t.timestamps
    end
  end
end
