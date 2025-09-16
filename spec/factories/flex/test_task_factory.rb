FactoryBot.define do
  factory :test_task, class: 'TestTask' do
    association :case, factory: :test_case
  end
end
