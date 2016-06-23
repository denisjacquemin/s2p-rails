class Addurltoschools < ActiveRecord::Migration[5.0]
  def change
    add_column :schools, :url, :string
  end
end
