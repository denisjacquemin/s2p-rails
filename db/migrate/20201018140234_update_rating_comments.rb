class UpdateRatingComments < ActiveRecord::Migration[5.2]
  def change
    add_column :rating_comments, :student_id, :integer
    add_column :rating_comments, :period_id, :integer
    add_column :rating_comments, :year_id, :integer
    add_column :rating_comments, :content, :text
    remove_column :rating_comments, :order
    remove_column :rating_comments, :name
  end
end
