class AddSchoolIdToPeriods < ActiveRecord::Migration[5.2]
  def change
    add_column :periods, :school_id, :integer
  end
end
