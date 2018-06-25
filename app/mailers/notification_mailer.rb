class NotificationMailer < ApplicationMailer

  def approval_requested(emails, message_title, author_firstname, author_lastname)
    @message_title = message_title
    @author_firstname = author_firstname
    @author_lastname = author_lastname
    mail(to: emails, subject: "[Konecto] #{author_firstname} demande une approbation: #{message_title[0..50]}")
  end
end
