class WebsiteController < ApplicationController
  layout false

  def contactme
    WebsiteMailer.thanks_email(
      params[:name],
      params[:email],
      params[:tel],
      params[:message]).deliver
  end

end
