class UpdateGradesJob < ApplicationJob
  queue_as :update_grades_on_import

  def perform(school_id)

   # get all the grades for all school's students by querying the Students table
   Student.where(school_id: school_id).pluck(:grade).uniq.compact
   # get all the grades for the school by querying the Grades table
   
   # gets the Grades to create
   # gets the Grades to delete

  end
end
