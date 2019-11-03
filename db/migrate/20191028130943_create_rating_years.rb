class CreateRatingYears < ActiveRecord::Migration[5.2]
  def change
    create_table :rating_years do |t|
      t.string :name
      t.integer :order
      t.boolean :active
      t.integer :school_id

      t.timestamps
    end
  end
end
