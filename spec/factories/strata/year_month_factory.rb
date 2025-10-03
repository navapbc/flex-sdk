# frozen_string_literal: true

FactoryBot.define do
  factory :year_month, class: 'Strata::YearMonth' do
    year { Faker::Number.between(from: 1950, to: 2050) }
    month { Faker::Number.between(from: 1, to: 12) }

    trait :invalid do
      month { 13 }
    end
  end
end
