module Flex
  class PassportApplicationForm < ApplicationForm
    attribute :first_name, :string
    attribute :last_name, :string
    attribute :date_of_birth, :date

    has_one :passport_case, class_name: 'Flex::PassportCase', foreign_key: :passport_application_form_id, dependent: :destroy

    before_update :prevent_submition_if_missing_fields, if: :is_submitting?
    after_create :create_passport_case

    def submit_application
      if has_all_necessary_fields?
        super
      else
        errors.add(:base, "Missing necessary fields for passport application")
        false
      end
    end

    def has_all_necessary_fields?
      first_name.present? && last_name.present? && date_of_birth.present?
    end

    private

    def create_passport_case
      passport_case = PassportCase.create(passport_application_form: self)
    end

    def prevent_submition_if_missing_fields
      if !has_all_necessary_fields?
        errors.add(:base, "Missing necessary fields for passport application")
        throw :abort
      end
    end
  end
end
