class AddAllGroupsToRatingYears < ActiveRecord::Migration[5.2]
  def change
    add_column :rating_years, :all_groups, :boolean, default: true
  end
end
