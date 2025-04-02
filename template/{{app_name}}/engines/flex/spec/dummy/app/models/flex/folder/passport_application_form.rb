module Flex
  class PassportApplicationForm < ApplicationForm
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :date_of_birth, :date

    has_one :passport_case, class_name: 'Flex::PassportCase', foreign_key: :passport_application_form_id, dependent: :destroy

    after_create :create_passport_case

    private

    def create_passport_case
      PassportCase.create(passport_application_form: self)
    end
  end
end
