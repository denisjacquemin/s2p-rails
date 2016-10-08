# Preview all emails at http://localhost:3000/rails/mailers/message_mailer
class MessageMailerPreview < ActionMailer::Preview

  def message_email
    # /rails/mailers/message_mailer/message_email
    MessageMailer.message_email('me@example.com', Message.find(6))
  end
end
