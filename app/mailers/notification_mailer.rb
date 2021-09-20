class NotificationMailer < ApplicationMailer

  def approval_requested(emails, message_title, author_firstname, author_lastname, implantation)
    @message_title = message_title
    @author_firstname = author_firstname
    @author_lastname = author_lastname
    @implantation = implantation
    mail(to: emails, subject: "[Konecto] #{author_firstname} demande une approbation: #{message_title[0..50]}")
  end

  def approved(emails, message_title, implantation)
    @message_title = message_title
    @implantation = implantation
    mail(to: emails, subject: "[Konecto] Votre message est approuvé: #{message_title[0..50]}")
  end

  def refused(emails, message_title, implantation)
    @message_title = message_title
    @implantation = implantation
    mail(to: emails, subject: "[Konecto] Votre message est refusé: #{message_title[0..50]}")
  end
end
