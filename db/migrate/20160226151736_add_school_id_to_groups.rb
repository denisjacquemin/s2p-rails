class AddSchoolIdToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :school_id, :integer
  end
end
