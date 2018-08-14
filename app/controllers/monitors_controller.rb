class MonitorsController < ApplicationController

  before_action :authenticate_user!

  def index
    if current_user.superadmin?
       @latest_logged_users = User.order('last_sign_in_at IS NULL, last_sign_in_at DESC').limit(15)
    else
       redirect_to root_url # or whatever
    end
  end

end
