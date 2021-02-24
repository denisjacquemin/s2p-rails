class AddAverageToRatings < ActiveRecord::Migration[5.2]
  def change
    add_column :ratings, :average, :string
  end
end
