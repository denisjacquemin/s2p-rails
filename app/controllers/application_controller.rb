class ApplicationController < ActionController::Base

  before_action :configure_permitted_parameters, if: :devise_controller?

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_school

  private

  def user_not_authorized
    flash[:alert] = "vous n'êtes pas autorisé à consulter cette page."
    redirect_to(request.referrer || root_path)
  end

  def current_school
    if session[:current_school].nil?
      if current_user.superadmin?
        s = School.first
        session[:current_school] = s.id
        return s
      else
        session[:current_school] ||= current_user.schools_obj[0].id
      end
    end
    School.find(session[:current_school])
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [:email, :firstname, :lastname])
  end
end
