class AddFollowedToStudents < ActiveRecord::Migration[5.0]
  def change
    add_column :students, :followers, :integer, default: 0
  end
end
