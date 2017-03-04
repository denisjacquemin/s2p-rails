class AddSendCodeTemplateToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :send_code_template, :text
  end
end
