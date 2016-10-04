class AddUniqueIndexToCode < ActiveRecord::Migration[5.0]
  def change
    add_index :groups, :code, unique: true
    add_index :groups, [:school_id, :name], :unique => true
    add_index :students, :code, unique: true
  end
end
