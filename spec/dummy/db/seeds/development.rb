# frozen_string_literal: true

users = 10.times.collect do |index|
  User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )
end

50.times do |index|
  application_form = PassportApplicationForm.create!(
    name_first: Faker::Name.first_name,
    name_last: Faker::Name.last_name,
    date_of_birth: Faker::Date.birthday(min_age: 0, max_age: 130),
  )
end

PassportApplicationForm.order('RANDOM()').limit(10).each do |application_form|
  application_form.submit_application
end

