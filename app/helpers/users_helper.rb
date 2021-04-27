module UsersHelper
    def has_access_to_group(user, group_id)
        checked_group = false
        # if a ReportGroupUser exist get the allowed value otherwise check user.groups
        report_group = ReportGroupUser.where('user_id = ? and report_group_users.group_id = ?', user.id, group_id).first
        unless report_group.nil?
            checked_group = report_group.allowed
        else
            checked_group = true if user.groups.pluck(:id).include?(group_id)
        end
        checked_group
    end

    def has_access_to_competency(user, group_id, competency_id)
        checked_group = has_access_to_group(user, group_id)
        checked_competency = false
        access_right = ReportCompetencyUser.find_by(competency_id: competency_id, user_id: user.id)
        unless access_right.nil?
            checked_competency = access_right.allowed
        else
            checked_competency = checked_group
        end
        checked_competency
    end
end