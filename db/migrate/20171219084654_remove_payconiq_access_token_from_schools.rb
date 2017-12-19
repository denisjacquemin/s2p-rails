class RemovePayconiqAccessTokenFromSchools < ActiveRecord::Migration[5.0]
  def change
    remove_column :schools, :payconiq_access_token
  end
end
