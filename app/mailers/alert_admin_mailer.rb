class AlertAdminMailer < ApplicationMailer

  def send_alert(msg)
    @msg = msg
    mail(to: 'denis.jacquemin@gmail.com', subject: "Alert S2P" )
  end

end
