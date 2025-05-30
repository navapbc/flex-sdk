FactoryBot.define do
  factory :name, class: Flex::Name do
    middle { nil }

    trait :base do
      first { Faker::Name.first_name }
      last { Faker::Name.last_name }
    end
  
    trait :with_middle do
      middle { Faker::Name.middle_name }
    end

    initialize_with { new(first, middle, last) }
  end
end
