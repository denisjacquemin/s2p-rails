class InvitationsController < Devise::InvitationsController

  def create
    self.resource = invite_resource
    resource_invited = resource.errors.empty?

    yield resource if block_given?

    if resource_invited
      if is_flashing_format? && self.resource.invitation_sent_at

        set_flash_message :notice, :send_instructions, :email => self.resource.email
      end
      if self.method(:after_invite_path_for).arity == 1
        respond_with resource, :location => after_invite_path_for(current_inviter)
      else
        respond_with resource, :location => users_path
      end
    else
      respond_with_navigational(resource) { render :new }
    end
  end

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
