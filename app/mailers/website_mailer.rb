class WebsiteMailer < ApplicationMailer

  def thanks_email(name, email, tel, message)
    @name = name
    @tel = tel
    @email = email
    @message = message
    mail(bcc: 'konecto@konectoapp.com', to: email, subject: "Contact Konecto App")
  end
end
