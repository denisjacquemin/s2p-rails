class SupportMailer < ApplicationMailer

  def confirm_email(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(bcc: 'konecto@konectoapp.com', to: email, subject: "Konecto App demande de support")
  end
end
