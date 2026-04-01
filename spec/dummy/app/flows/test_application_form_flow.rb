# frozen_string_literal: true

# Flow used by generator specs to test view generation against real model attributes.
class TestApplicationFormFlow
  include Strata::Flows::ApplicationFormFlow

  task :personal_information do
    question_page :applicant_name, fields: [ :applicant_name ]
    question_page :date_of_birth, fields: [
      date_of_birth: [ :month, :day, :year ]
    ]
    question_page :mailing_address, fields: [ :mailing_address ]
    question_page :ssn, fields: [ :ssn ]
  end

  task :employment do
    question_page :employer_name, fields: [ :employer_name ]
    question_page :salary, fields: [ :salary ]
    question_page :hire_date, fields: [ :hire_date ]
    question_page :leave_type, fields: [ :leave_type ]
  end

  task :additional_info do
    question_page :reviewed, fields: [ :reviewed ]
    question_page :start_date, fields: [ :start_date ]
    question_page :notes, fields: [ :notes ]
    question_page :age, fields: [ :age ]
    question_page :contact_info, fields: [ :employer_name, :notes ]
    question_page :details, fields: [ :employer_name, :income_records_attributes ]
    question_page :documents, fields: [ :resume ]
    question_page :info, fields: [ :employer_name, :flow_only_field ]
  end

  end_page :review
end
