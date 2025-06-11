FactoryBot.define do
  factory :money, class: 'Flex::Money' do
    cents { Faker::Number.between(from: -100000, to: 100000) }

    initialize_with { Flex::Money.new(cents) }
  end
end
