class ApplicationMailer < ActionMailer::Base
  default from: ENV["SES_EMAIL"]
  layout "mailer"
end
