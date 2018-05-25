class CreateJoinTableStudentsMessageCategory < ActiveRecord::Migration[5.0]
  def change
    create_join_table :students, :message_categories do |t|
      # t.index [:student_id, :message_category_id]
      # t.index [:message_category_id, :student_id]
    end
  end
end
