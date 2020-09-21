class AddMissingIndexes < ActiveRecord::Migration[5.2]
  def change
    add_index :groups, :school_id
    add_index :groups_users, [:group_id, :user_id]
    add_index :messages, :author_id
    add_index :messages, :school_id
    add_index :mfiles, :message_id
    add_index :phones, :student_id
    add_index :recipients, :message_id
    add_index :recipients, :school_id
    add_index :students, :school_id
    add_index :students_users, [:student_id, :user_id]
  end
end
