class AddSettingsValidationWorkflowActiveToSchools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :validation_workflow_active, :boolean, default: true
  end
end
