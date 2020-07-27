class AddNewRecipientsSelectionColumnToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :new_recipients_selection, :boolean, default: false
  end
end
