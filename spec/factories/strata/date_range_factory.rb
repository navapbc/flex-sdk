# frozen_string_literal: true

FactoryBot.define do
  factory :date_range, class: 'Strata::DateRange' do
    add_attribute(:start) { Strata::USDate.cast(Faker::Date.between(from: 100.days.ago, to: Date.today)) }
    add_attribute(:end) { Strata::USDate.cast(Faker::Date.between(from: Date.today, to: Date.today + 100.days)) }
  end
end
