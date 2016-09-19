class InvitationsController < Devise::InvitationsController

  private
    def invite_resource
        resource_class.invite!(invite_params, current_inviter) do |invitable|
            if invitable.errors.empty?
              if current_user.admin?
                invitable.schools << current_school.id
              end
              if current_user.superadmin?
                invitable.admin!
                invitable.schools << current_school.id
              end
            end
            invitable
        end
    end
end
