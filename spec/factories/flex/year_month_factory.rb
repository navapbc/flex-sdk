FactoryBot.define do
  factory :year_month, class: 'Flex::YearMonth' do
    year { Faker::Number.between(from: 1950, to: 2050) }
    month { Faker::Number.between(from: 1, to: 12) }

    trait :invalid do
      month { 13 }
    end
  end
end
