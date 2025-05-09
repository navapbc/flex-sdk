10.times do |index|
  User.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    id: SecureRandom.uuid
  )
end

50.times do |index|
  PassportApplicationForm.create!(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    date_of_birth: Faker::Date.birthday(min_age: 0, max_age: 130),
  )
end

ten_days_ago = Date.current - 10.days
20.times do |index|
  task = PassportVerifyInfoTask.create!(
    description: "Task description for #{index}",
    due_on: ten_days_ago + index.days,
    case_id: PassportCase.pluck(:id).sample
  )

  task.assign(User.pluck(:id).sample)
  task.mark_completed if rand(0..2) == 0
end

20.times do |index|
  task = PassportPhotoTask.create!(
    description: "Task description for #{index}",
    due_on: ten_days_ago + index.days,
    case_id: PassportCase.pluck(:id).sample
  )

  task.assign(User.pluck(:id).sample)
  task.mark_completed if rand(0..5) == 0
end
