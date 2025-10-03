# frozen_string_literal: true

FactoryBot.define do
  factory :application_form do
    association :case, factory: :test_case

    trait :with_applicant do
      association :applicant, factory: :user
    end
  end
end
