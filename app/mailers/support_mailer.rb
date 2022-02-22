class SupportMailer < ApplicationMailer

  def confirm_email(name, email, message)
    @name = name
    @email = email
    @message = message
    mail(bcc: 'konecto@konectoapp.com', to: email, subject: "Konecto App demande de support")
  end

  def contact_sdui_email(name, email, schools, message)
    @name = name
    @email = email
    @schools = schools
    @message = message
    mail( to: 'maximilien.ami@sdui.de, artavazd.andranikyan@sdui.de, dominik.nitsch@sdui.de, denis@konectoapp.com,', subject: "Sdui communication feedback")
  end
end
