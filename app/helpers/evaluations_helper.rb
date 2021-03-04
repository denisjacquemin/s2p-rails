module EvaluationsHelper

    def groups_and_options_for_competencies(competencies)
        competencies.map do |competency|
            unless competency.is_totals
                if competency.title_only
                    tag = "<optgroup label='#{competency.name}'>"
                    tag = "</optgroup>" + tag if competency.level == 1
                    tag
                else
                    tag = "<option value=#{competency.id}>#{competency.name}</option>"
                    tag = "</optgroup>" + tag if competency.level == 1
                    tag
                end
            end
        end.join.html_safe

    end
end