class PopulateStudentPhonesCount < ActiveRecord::Migration[5.2]
  def change
    Student.find_each do |student|
      Student.reset_counters(student.id, :phones)
    end
  end
end
