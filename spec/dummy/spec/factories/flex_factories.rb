FactoryBot.define do
  factory :passport_case do
    # Add any necessary attributes for PassportCase
  end

  factory :passport_task do
    description { Faker::Lorem.sentence }
    due_on { 1.week.from_now }
    association :case, factory: :passport_case
  end

  # Test helper factories
  factory :test_case, class: 'TestCase' do
  end

  factory :other_test_case, class: 'OtherTestCase' do
  end
end
