class DeviseMailerPreview < ActionMailer::Preview
  def reset_password_instructions
    # /rails/mailers/devise_mailer/reset_password_instructions
    user = User.new(firstname: "Jimmy", email: "jkasdfklajsl@askdfjlas.com")
    Devise::Mailer.reset_password_instructions(user, "insertRandomTokenHere")
  end
end
