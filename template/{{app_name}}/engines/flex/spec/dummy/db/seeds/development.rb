5.times do |index|
  PassportCase.create!(
    passport_id: SecureRandom.uuid,
  )
end

30.times do |index|
  Flex::Task.create!(
    description: "Task description for #{index}",
    due_on: Date.today + (index - (index / 2)).days,
    case_id: PassportCase.pluck(:id).sample,
    assignee_id: nil # Will change this after adding user model in the future
  )
end