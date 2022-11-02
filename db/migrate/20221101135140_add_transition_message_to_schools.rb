class AddTransitionMessageToSchools < ActiveRecord::Migration[5.2]
  def change
    add_column :schools, :transition_message, :text
    add_column :schools, :activate_transition_message, :boolean, default: false
  end
end
