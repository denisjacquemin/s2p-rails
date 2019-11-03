class DropSchoolYearTable < ActiveRecord::Migration[5.2]
  def change
    drop_table :school_years do |t|
      t.string :name
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end
  end
end
