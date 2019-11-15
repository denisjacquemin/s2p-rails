class CreateRatingComments < ActiveRecord::Migration[5.2]
  def change
    create_table :rating_comments do |t|
      t.string :name
      t.integer :school_id
      t.integer :order

      t.timestamps
    end
  end
end
