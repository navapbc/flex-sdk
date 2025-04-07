require_relative "../../../../../app/models/flex/application_form"
require_relative "../flex/passport_case"
# require_relative "../flex/passport_case"
module Flex
  class PassportApplicationForm < ApplicationForm
    after_create :create_passport_case
    
    has_one :passport_case, class_name: 'Flex::PassportCase'

    attribute :first_name, :string
    attribute :last_name, :string
    attribute :date_of_birth, :date

    def has_all_necessary_fields?
      !first_name.nil? && !last_name.nil? && !date_of_birth.nil?
    end

    def submit_application
      if has_all_necessary_fields?
        passport_case.update!(business_process_current_step: "verify identity")
        super
      end
    end

    private

    def create_passport_case
      PassportCase.create!({ passport_application_form: self })
    end
  end
end
