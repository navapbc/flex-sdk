# frozen_string_literal: true

FactoryBot.define do
  factory :test_application_form do
    user_id { create(:user).id }
    test_string { "Test String" }
  end
end
