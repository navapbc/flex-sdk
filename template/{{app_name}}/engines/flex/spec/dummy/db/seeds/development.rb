5.times do |index|
  PassportCase.create!(
    passport_id: SecureRandom.uuid,
  )
end

ten_days_ago = Date.current - 10.days
20.times do |index|
  task = PassportTask.create!(
    description: "Task description for #{index}",
    due_on: ten_days_ago + index.days,
    case_id: PassportCase.pluck(:id).sample,
    assignee_id: nil # Will change this after adding user model in the future
  )

  task.mark_completed if index % 5 == 0
end

20.times do |index|
  task = PassportPhotoTask.create!(
    description: "Task description for #{index}",
    due_on: ten_days_ago + index.days,
    case_id: PassportCase.pluck(:id).sample,
    assignee_id: nil # Will change this after adding user model in the future
  )

  task.mark_completed if index % 4 == 0
end
