class Rating < ApplicationRecord
    belongs_to :student
    belongs_to :school
    belongs_to :competency
    belongs_to :rating_year

    validates_uniqueness_of :student_id, :scope => [:school_id, :competency_id, :period_id, :rating_year_id]

    # t.string "rating"
    # t.string "comment"
    # t.integer "student_id"
    # t.integer "school_id"
    # t.integer "competency_id"
    # t.integer "period_id"


    # belongs_to :period

    scope :by_competency, -> (competency_id) { where(competency_id: competency_id) }
    scope :by_period, -> (period_id) { where(period_id: period_id) }
    scope :by_rating_year, -> (rating_year_id) { where(rating_year_id: rating_year_id) }
    
    def self.isAValidFloat(stringToTest)
      /\d+[,.]?\d*/ === stringToTest
    end


    def self.computeAverage(competency_id, school_id, group_id, period_id, student_id)
      
      # trouver la ponderation de la competence 
      competency_weight = Competency.select(:weight).find(competency_id).weight

      # si cette ponderation est valide (un float)
      if isAValidFloat(competency_weight)
      
        # le calcul peut commencer, initialiser la somme des quotes et leur total maximum
        sum = 0.0
        maxsum = 0.0
        # Pour toutes les evaluations 
        evaluations_for_average = Evaluation.where(school_id: school_id, group_id: group_id, period_id: period_id, competency_id: competency_id)
        evaluations_for_average.each do |evaluation|

          # si l'evaluation posede une ponderation correcte
          if isAValidFloat(evaluation.weight) # don't take quotations for average because the weight is not valid
            # recuperer la quotation de cette evaluation pour cet eleve
            quotations = Quotation.where(student_id: student_id, school_id: school_id, evaluation_id: evaluation.id)
            if quotations.size == 1
              # Si on en a trouvé une valide et qu'il faut en tenir compte (averageable)
              if quotations[0].averageable and isAValidFloat(quotations[0].value)
                sum += quotations[0].value.gsub(',', '.').to_f
                maxsum += evaluation.weight.gsub(',', '.').to_f
              end
            end
          end
        end
        rating = Rating.find_or_create_by(student_id: student_id, school_id: school_id, competency_id: competency_id, period_id: period_id)
        average = ((sum.to_f / maxsum) * competency_weight.to_f).round(1)
        rating.update_column('average', average)
        # Les ratings ont changez donc les totaux doivent etre mis à jour
        ComputeTotalRatingsJob.perform_later(school_id: school_id, student_id: student_id, competency_id: competency_id, period_id: period_id, group_id: group_id)
      end
    end
end
