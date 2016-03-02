class CreateStudents < ActiveRecord::Migration[5.0]
  def change
    create_table :students do |t|
      t.string :firstname
      t.string :lastname
      # see http://edgeguides.rubyonrails.org/active_record_postgresql.html#array
      # see http://blog.plataformatec.com.br/2014/07/rails-4-and-postgresql-arrays/
      # see http://stackoverflow.com/questions/24236871/in-rails-how-to-add-an-element-to-an-array-type-attribute-for-all-records
      t.integer :groups, array: true, default: []
      t.timestamps
    end
  end
end
