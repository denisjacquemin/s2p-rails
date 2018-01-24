class CreateFormTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :form_templates do |t|
      t.string :name
      t.integer :school_id
      t.json :formdata
      t.integer :author_id

      t.timestamps
    end
  end
end
