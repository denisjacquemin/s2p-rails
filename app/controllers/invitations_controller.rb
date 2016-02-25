class InvitationsController < Devise::InvitationsController
  private
    def invite_resource
        resource_class.invite!(invite_params, current_inviter) do |invitable|
            byebug
            if current_user.admin?
              invitable.school_id = current_user.school_id
            end
        end
    end
end
