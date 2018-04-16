class AlertAdminMailer < ApplicationMailer

  def send_alert(msg)
    byebug
    @msg = msg
    mail(from: "S2P App", to: 'denis.jacquemin@gmail.com', subject: "Alert S2P" )
  end

end
