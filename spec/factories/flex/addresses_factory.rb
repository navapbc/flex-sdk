FactoryBot.define do
  factory :address, class: 'Flex::Address' do
    trait :base do
      street_line_1 { Faker::Address.street_address }
      street_line_2 { nil }
      city { Faker::Address.city }
      state { Faker::Address.state_abbr }
      zip_code { Faker::Address.zip_code }
    end

    trait :with_street_line_2 do
      street_line_2 { Faker::Address.secondary_address }
    end
  end
end
