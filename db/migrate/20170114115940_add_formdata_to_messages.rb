class AddFormdataToMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :messages, :formdata, :json
  end
end
