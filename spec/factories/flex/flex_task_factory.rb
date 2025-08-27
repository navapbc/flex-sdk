FactoryBot.define do
  factory :flex_task, class: 'Flex::Task' do
    description { Faker::Lorem.sentence }
    due_on { 1.week.from_now }
    association :case, factory: :test_case
  end
end
