class AddPayconiqAccessTokenToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :payconiq_access_token, :string
  end
end
