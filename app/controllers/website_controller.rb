class WebsiteController < ApplicationController
  layout false

  def contactme

    if verify_recaptcha()
      WebsiteMailer.thanks_email(
        params[:name],
        params[:email],
        params[:tel],
        params[:message]).deliver

        render 'contactme'
    else
      render 'recaptcha_error'
    end
  end

end
