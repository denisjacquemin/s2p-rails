class ComputeTotalRatingsJob < ApplicationJob
    queue_as :default

  
    def perform(args)
      # the goal is to compute if necessary, totals for a given student_id  and a given period_id
      student_id = args[:student_id]
      school_id = args[:school_id]
      competency_id = args[:competency_id]
      period_id = args[:period_id]
      group_id = args[:group_id]
      
      student = Student.find(student_id)

      # get all competencies ordered for a given group id, the goals is to find the same level competenmcies to compute totals
      competencies = Competency.where(school_id: school_id, group_id: group_id).order(:order)

      # init maxsum, sum and previous_level to 0
      sum = 0.0
      maxsum = 0
      previous_level = 0
      
      # run through all competencies, compute maxsum and max and totals
      competencies.each do |competency|
        if competency.level >= previous_level # continue the sum
          # if current competency is a total competency, the write the Rating with the computed average of sum and maxsum based on competency.weight
          if competency.is_totals?
            puts "Totals!!!!!!!! [#{sum}] [#{maxsum}] [#{competency.weight}]"
            if !competency.weight.blank? && sum > 0 
              rating_value = (sum / maxsum) * competency.weight.to_f

              rating = Rating.find_or_create_by(school_id: school_id, competency_id: competency.id, student_id: student_id, period_id: period_id)
              rating.update_columns(rating: rating_value)
            end

          # else if current competency is not a total competency, continue the sum
          else
            # only if current competency has a weight
            if !competency.weight.blank?
              rating = Rating.where(school_id: school_id, competency_id: competency.id, student_id: student_id, period_id: period_id)
              if !rating.first.nil? and (!rating[0].rating.blank? ||  !rating[0].average.blank?)
                rating_value = nil
                if !rating[0].rating.blank?
                  rating_value = rating[0].rating
                elsif !rating[0].average.blank?
                  rating_value = rating[0].average
                end
                if !rating_value.nil?
                  sum += rating_value.to_f 
                  maxsum += competency.weight.to_i
                end
              end
            end
          end
        elsif competency.level < previous_level
          sum = maxsum = 0
        end
        previous_level = competency.level
      end
    end
end