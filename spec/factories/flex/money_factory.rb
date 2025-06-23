FactoryBot.define do
  factory :money, class: 'Flex::Money' do
    cents { Faker::Number.between(from: -100000, to: 100000) }
  end
end
