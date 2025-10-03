# frozen_string_literal: true

FactoryBot.define do
  factory :year_quarter, class: 'Strata::YearQuarter' do
    year { Faker::Number.between(from: 1950, to: 2050) }
    quarter { Faker::Number.between(from: 1, to: 4) }

    trait :invalid do
      quarter { 5 }
    end
  end
end
