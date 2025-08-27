FactoryBot.define do
  factory :flex_task, class: 'Flex::Task' do
    association :case, factory: :test_case

    trait(:description) do
      description { Faker::Lorem.sentence }
    end
    trait(:due_on) do
      due_on { 1.week.from_now }
    end
  end
end
