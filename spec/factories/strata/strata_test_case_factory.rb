# frozen_string_literal: true

FactoryBot.define do
  factory :test_case, class: 'TestCase' do
    trait :with_application_form do
      after(:create) do |test_case|
        create(:application_form, case: test_case)
      end
    end
  end
end
