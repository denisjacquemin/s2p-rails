class AddRatingYearIdToRatings < ActiveRecord::Migration[5.2]
  def change
    add_column :ratings, :rating_year_id, :integer
  end
end
