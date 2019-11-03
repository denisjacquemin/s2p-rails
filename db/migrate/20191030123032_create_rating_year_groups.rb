class CreateRatingYearGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :rating_year_groups do |t|
      t.integer :group_id
      t.integer :rating_year_id

      t.timestamps
    end
  end
end
