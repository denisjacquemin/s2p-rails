class CreateAccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :accounts do |t|
      t.string :name
      t.integer :school_id
      t.string :payconiq_access_token
      t.string :account_number

      t.timestamps
    end
  end
end
