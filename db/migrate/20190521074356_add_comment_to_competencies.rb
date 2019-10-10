class AddCommentToCompetencies < ActiveRecord::Migration[5.2]
  def change
    add_column :competencies, :comment, :string
  end
end
