# frozen_string_literal: true

FactoryBot.define do
  factory :passport_application_form do
    trait :base do
      name { build(:name, :base) }
      date_of_birth { Faker::Date.birthday(min_age: 18, max_age: 65) }
    end
  end
end
