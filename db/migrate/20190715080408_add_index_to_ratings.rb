class AddIndexToRatings < ActiveRecord::Migration[5.2]
  def change
    # validates_uniqueness_of :student_id, :scope => [:school_id, :competency_id, :period_id]

    add_index :ratings, [:student_id, :school_id, :competency_id, :period_id], unique: true, :name => 'index_ratings_uniqueness'
  end
end
