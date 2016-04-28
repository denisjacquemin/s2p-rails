class InvitationsController < Devise::InvitationsController

  private
    def invite_resource
        resource_class.invite!(invite_params, current_inviter) do |invitable|
            if current_user.admin?
              invitable.school_id = current_user.school_id
            end
            if current_user.superadmin?
              invitable.admin!
            end
        end
    end
end
