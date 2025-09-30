module Flex
  # ApplicantTask represents a task that requires interaction from the applicant.
  # It is used in business processes to create tasks that applicants
  # need to complete.
  #
  # @example Defining an applicant task in a business process
  #   bp.step('submit_documents',
  #     Flex::ApplicantTask.new("Submit Documents"))
  #
  # Key features:
  # - Simple logging of task execution
  # - Integration with business processes for applicant workflow
  #
  class ApplicantTask
    include Step

    attr_reader :name

    def initialize(name)
      @name = name
    end

    def execute(kase)
      Rails.logger.info "Executing ApplicantTask '#{name}' for case ID: #{kase.id}"
    end
  end
end
