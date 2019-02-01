class AddAllowTranslationToSchool < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :allow_translation, :boolean, default: :false
  end
end
