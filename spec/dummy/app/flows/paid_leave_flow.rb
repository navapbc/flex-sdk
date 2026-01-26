# frozen_string_literal: true

# Dummy paid leave flow
class PaidLeaveFlow
  include Strata::Flows::ApplicationFormFlow
  task :personal_information do
    question_page :name, fields: [ :applicant_name_first ]
    question_page :date_of_birth, fields: [
      date_of_birth: [ :month, :day, :year ]
    ]
  end
  task :employment_details do
    question_page :employer_name
  end
  task :leave_details do
    question_page :leave_type
  end
  end_page :review
end
