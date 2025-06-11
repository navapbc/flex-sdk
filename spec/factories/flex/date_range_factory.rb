FactoryBot.define do
  factory :date_range, class: 'Range' do
    add_attribute(:begin) { Faker::Date.between(from: 100.days.ago, to: Date.today) }
    add_attribute(:end) { Faker::Date.between(from: Date.today, to: Date.today + 100.days) }

    initialize_with { Range.new(attributes[:begin], attributes[:end]) }
  end
end
