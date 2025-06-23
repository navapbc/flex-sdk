FactoryBot.define do
  factory :date_range, class: 'Flex::DateRange' do
    add_attribute(:start) { Flex::USDate.cast(Faker::Date.between(from: 100.days.ago, to: Date.today)) }
    add_attribute(:end) { Flex::USDate.cast(Faker::Date.between(from: Date.today, to: Date.today + 100.days)) }
  end
end
