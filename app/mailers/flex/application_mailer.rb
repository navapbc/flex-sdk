module Flex
  # ApplicationMailer is the base class for all mailers in the Flex SDK.
  # It provides default settings and layouts for email templates.
  #
  # This class inherits from ActionMailer::Base and sets default sender
  # and layout configuration.
  #
  class ApplicationMailer < ActionMailer::Base
    default from: "from@example.com"
    layout "mailer"
  end
end
