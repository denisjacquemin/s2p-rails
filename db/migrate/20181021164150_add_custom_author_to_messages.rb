class AddCustomAuthorToMessages < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :custom_author, :string
  end
end
