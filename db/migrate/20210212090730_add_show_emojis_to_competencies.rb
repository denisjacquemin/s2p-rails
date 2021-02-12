class AddShowEmojisToCompetencies < ActiveRecord::Migration[5.2]
  def change
    add_column :competencies, :show_emojis, :boolean, default: false
  end
end
