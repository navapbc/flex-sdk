# frozen_string_literal: true

FactoryBot.define do
  factory :test_case do
    initialize_with {
      application_form = create(:test_application_form)
      TestCase.find_or_create_by!(application_form_id: application_form.id)
    }
  end
end
