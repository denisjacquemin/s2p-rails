class AddDeletedAtToCompetencies < ActiveRecord::Migration[5.2]
  def change
    add_column :competencies, :deleted_at, :datetime
  end
end
