module DeviseHelper
  def devise_error_messages!
    flash[:alert] = resource.errors.full_messages.map { |msg|  msg }.join unless resource.errors.full_messages.empty?
  end
end
