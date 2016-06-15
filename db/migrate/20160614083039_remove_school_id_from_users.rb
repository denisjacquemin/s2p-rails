class RemoveSchoolIdFromUsers < ActiveRecord::Migration[5.0]
  def change
    remove_column :users, :school_id
  end
end
