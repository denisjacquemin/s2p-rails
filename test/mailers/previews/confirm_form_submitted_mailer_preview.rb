# Preview all emails at http://localhost:3000/rails/mailers/confirm_form_submitted_mailer
class ConfirmFormSubmittedMailerPreview < ActionMailer::Preview

  def send_confirmation
    ConfirmFormSubmittedMailer.send_confirmation(['me@example.com'], 66)
  end
end
