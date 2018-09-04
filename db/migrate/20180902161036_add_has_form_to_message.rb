class AddHasFormToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :has_form, :boolean, default: :false
  end
end
