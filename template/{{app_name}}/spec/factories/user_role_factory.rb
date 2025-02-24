FactoryBot.define do
  factory :user_role do
    user

    trait :applicant do
      role { "applicant" }
    end

    trait :employer do
      role { "employer" }
    end

    trait :superadmin do
      role { "superadmin" }
      user { create(:user, :superadmin) }
    end
  end
end
