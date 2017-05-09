class FaqController < ApplicationController
  def show
    @admins = current_school.admins
  end

  def help
  end

  def contact_support

  end

  def submit_support
    SupportMailer.confirm_email(
      params[:name],
      params[:email],
      params[:message]).deliver

    render 'supportconfirmation'
  end
end
