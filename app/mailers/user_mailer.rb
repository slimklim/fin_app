class UserMailer < ActionMailer::Base
  default from: "system@fin-app.com"

  def registration_confirmation(user)
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: "Confirmation Registration")
  end

  def password_reset(user)
    @user = user
    mail(to: "#{user.name} <#{user.email}>", subject: "Reset Password")
  end
end