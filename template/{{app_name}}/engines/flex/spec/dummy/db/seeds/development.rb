users = 10.times.collect do |index|
  User.new(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name
  )
end
User.insert_all(users)

50.times do |index|
  PassportCase.create!(
    passport_id: SecureRandom.uuid,
  )
end

ten_days_ago = Date.current - 10.days
20.times do |index|
  task = PassportVerifyInfoTask.create!(
    description: "Task description for #{index}",
    due_on: ten_days_ago + index.days,
    case_id: PassportCase.pluck(:id).sample
  )

  task.mark_completed if rand(0..2) == 0
end

20.times do |index|
  task = PassportPhotoTask.create!(
    description: "Task description for #{index}",
    due_on: ten_days_ago + index.days,
    case_id: PassportCase.pluck(:id).sample
  )

  task.mark_completed if rand(0..5) == 0
end
