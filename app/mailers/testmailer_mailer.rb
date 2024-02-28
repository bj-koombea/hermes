class TestmailerMailer < ApplicationMailer
  def send_email(email, subject, body)
    @email = email
    @subject = subject
    @body = body
    puts "enviando email"
    mail(to: @email, subject: @subject)
  end
end
