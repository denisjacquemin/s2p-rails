class CreateStudentsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :students_users, id: false do |t|
      t.belongs_to :student
      t.belongs_to :user
    end
  end
end
