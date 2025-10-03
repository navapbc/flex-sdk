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

  PassportCase.create!(
    application_form_id: application_form.id,
  )
end

passport_cases = PassportCase.all
ten_days_ago = Date.current - 10.days
20.times do |index|
  task = PassportVerifyInfoTask.create!(
    description: "Task description for #{index}",
    due_on: ten_days_ago + index.days,
    case: passport_cases.sample
  )

  task.assign(users.sample.id)
  task.completed! if rand(0..2) == 0
end

20.times do |index|
  task = PassportPhotoTask.create!(
    description: "Task description for #{index}",
    due_on: ten_days_ago + index.days,
    case: passport_cases.sample
  )

  task.assign(users.sample.id)
  task.completed! if rand(0..5) == 0
end

5.times do
  # Create tasks without a due_on date
  passport_cases.sample.create_task(PassportVerifyInfoTask)
end
