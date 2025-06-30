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

    attribute :application_form_id, :string

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, open: 0, closed: 1

    attribute :business_process_current_step, :string
    attribute :facts, :jsonb, default: {}

    scope :for_application_form, ->(application_form_id) { where(application_form_id:) }
    scope :for_event, ->(event) do
      if event[:payload].key?(:application_form_id)
        Rails.logger.debug "Finding business processes for event with application_form_id: #{event[:payload][:application_form_id]}"
        for_application_form(event[:payload][:application_form_id])
      else
        Rails.logger.debug "Finding business processes for event with case_id: #{event[:payload][:case_id]}"
        where(id: event[:payload][:case_id])
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
  end
end
