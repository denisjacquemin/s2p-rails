class AddSendCodeTitleTemplateToSchool < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :send_code_title_template, :string
  end
end
