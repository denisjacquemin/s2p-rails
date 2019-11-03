class RemoveActiveFromRatingYears < ActiveRecord::Migration[5.2]
  def change
    remove_column :rating_years, :active, :boolean
  end
end
