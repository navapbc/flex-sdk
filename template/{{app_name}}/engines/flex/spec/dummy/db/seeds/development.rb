5.times do |index|
  PassportCase.create!(
    passport_id: SecureRandom.uuid,
  )
end

fifteen_days_ago = Date.current - 15.days
30.times do |index|
  Flex::Task.create!(
    description: "Task description for #{index}",
    due_on: fifteen_days_ago + index.days,
    case_id: PassportCase.pluck(:id).sample,
    assignee_id: nil # Will change this after adding user model in the future
  )
end
