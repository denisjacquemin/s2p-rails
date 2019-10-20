class AddTitleOnlyToCompetencies < ActiveRecord::Migration[5.2]
  def change
    add_column :competencies, :title_only, :boolean, default: false
  end
end
