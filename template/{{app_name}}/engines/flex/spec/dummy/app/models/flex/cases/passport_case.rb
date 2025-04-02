module Flex
  class PassportCase < Case
    belongs_to :passport_application_form, class_name: 'Flex::PassportApplicationForm'
  end
end
