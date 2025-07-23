FactoryBot.define do
  factory :year_quarter, class: 'Flex::YearQuarter' do
    year { Faker::Number.between(from: 1950, to: 2050) }
    quarter { Faker::Number.between(from: 1, to: 4) }

    trait :invalid do
      year { Faker::Number.between(from: 1950, to: 2050) }
      quarter { 5 }
    end
  end
end
