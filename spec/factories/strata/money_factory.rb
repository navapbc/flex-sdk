# frozen_string_literal: true

FactoryBot.define do
  factory :money, class: 'Strata::Money' do
    cents { Faker::Number.between(from: -100000, to: 100000) }
  end
end
