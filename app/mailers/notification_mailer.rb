class NotificationMailer < ApplicationMailer

  def approval_requested(emails, message_title, author_firstname)
    @message_title = message_title
    @author_firstname = author_firstname
    mail(to: emails, subject: "[Konecto] #{author_firstname} demande une approbation: #{message_title[0..50]}")
  end
end
