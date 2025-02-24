FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }
    uid { Faker::Internet.uuid }
    provider { "factory_bot" }
    mfa_preference { "opt_out" }

    trait :applicant do
      user_role { create(:user_role, :applicant) }
    end

    trait :employer do
      user_role { create(:user_role, :employer) }
    end

    trait :superadmin do
      email { "test+admin@navapbc.com" }
    end
  end
end
