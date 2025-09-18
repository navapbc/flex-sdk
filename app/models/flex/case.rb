module Flex
  # Case represents an instance of a business process workflow.
  # It tracks the current step in the process and the overall status.
  #
  # Case models should inherit from this class and add their specific fields.
  #
  # @example Creating a case model
  #   class MyCase < Flex::Case
  #     # Add custom attributes or associations
  #   end
  #
  # Key features:
  # - Tracks the current step in a business process
  # - Manages case status (open/closed)
  # - Associates with an application form
  #
  class Case < ApplicationRecord
    self.abstract_class = true

    has_many :tasks, as: :case, class_name: "Flex::Task"

    # Returns the base attributes that should be included in all case migrations.
    # IMPORTANT: When adding new attributes to the Case model, add them here as well
    # to ensure they're included in migrations created by the generator.
    def self.base_attributes_for_generator
      [
        "application_form_id:uuid",
        "status:integer",
        "business_process_current_step:string",
        "facts:jsonb"
      ]
    end
    attribute :application_form_id, :uuid

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, open: 0, closed: 1

    attribute :business_process_current_step, :string
    attribute :facts, :jsonb, default: {}

    default_scope { includes(:tasks) }
    scope :closed, -> { where(status: :closed).order(created_at: :desc) }
    scope :for_application_form, ->(application_form_id) { where(application_form_id:) }
    scope :for_event, ->(event) do
      if event[:payload].key?(:case_id)
        Rails.logger.debug "Finding business processes for event with case_id: #{event[:payload][:case_id]}"
        where(id: event[:payload][:case_id])
      elsif event[:payload].key?(:application_form_id)
        Rails.logger.debug "Finding business processes for event with application_form_id: #{event[:payload][:application_form_id]}"
        for_application_form(event[:payload][:application_form_id])
      else
        Rails.logger.debug "No matching case or application form IDs found in event payload"
        none
      end
    end

    # Closes the case, changing its status to 'closed'.
    #
    # @return [Boolean] True if the save was successful
    def close
      self[:status] = :closed
      save
    end

    # Reopens a closed case, changing its status to 'open'.
    #
    # @return [Boolean] True if the save was successful
    def reopen
      self[:status] = :open
      save
    end

    def business_process_instance
      BusinessProcessInstance.new(self, business_process_current_step)
    end

    # Creates a new task associated with this case.
    #
    # @param task_class [Class] The class of the task to create (must be a subclass of Flex::Task)
    # @param attributes [Hash] Additional attributes to set on the task
    # @return [Flex::Task] The newly created task
    # @raise [ArgumentError] If task_class is not a subclass of Flex::Task
    def create_task(task_class, **attributes)
      raise ArgumentError, "task_class must be Flex::Task or a subclass of it" unless task_class <= Flex::Task

      task_class.create!(case: self, **attributes)
    end
  end
end
