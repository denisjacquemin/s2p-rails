class AddColumnGroupIdToCompetencies < ActiveRecord::Migration[5.2]
  def change
    add_column :competencies, :group_id, :integer
  end
end
