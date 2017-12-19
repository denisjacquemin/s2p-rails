class AddBillingEnableAndPayconiqEnableToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :billing_enable, :boolean, default: :false
    add_column :schools, :payconiq_enable, :boolean, default: :false
  end
end
