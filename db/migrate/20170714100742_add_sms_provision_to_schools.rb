class AddSmsProvisionToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :sms_provision, :integer, default: 0
  end
end
