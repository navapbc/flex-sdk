FactoryBot.define do
  factory :passport_task do
    description { Faker::Lorem.sentence }
    due_on { 1.week.from_now }
    association :case, factory: :passport_case
  end
end
