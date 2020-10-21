class UpdateRatingUniquenessIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :ratings, name: "index_ratings_uniqueness"
    add_index :ratings, [:student_id, :school_id, :competency_id, :period_id, :rating_year_id], unique: true, :name => 'index_ratings_uniqueness'
  end
end
