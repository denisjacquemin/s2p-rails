module Status extend ActiveSupport::Concern

    def validate_change_of_status(current_status, new_status, approval_workflow_active, user_role)

      # Approval Workflow is Active
      if approval_workflow_active
        return (current_status == :draft && new_status == :published && user_role == :admin)
      elsif !approval_workflow_active # Approval Workflow is not Active
        return (current_status == :draft && new_status == :published) ||
               (current_status == :published && new_status == :draft)
      end
    end
end
