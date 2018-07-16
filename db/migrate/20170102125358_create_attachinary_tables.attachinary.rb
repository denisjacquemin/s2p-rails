# This migration comes from attachinary (originally 20120612112526)
class CreateAttachinaryTables < ActiveRecord::Migration[5.0]
  def change
    create_table :attachinary_files do |t|
      t.references :attachinariable, polymorphic: true, index: {name: 'ndex_attach_files_on_attach_type_and_attach_id'}
      t.string :scope

      t.string :public_id
      t.string :version
      t.integer :width
      t.integer :height
      t.string :format
      t.string :resource_type
      t.timestamps
    end
    add_index :attachinary_files, [:attachinariable_type, :attachinariable_id, :scope], name: 'by_scoped_parent'
  end
end
