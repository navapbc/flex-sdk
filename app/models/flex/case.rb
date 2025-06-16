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
    attribute :facts, Flex::Attributes::FactsAttribute::FactsType.new

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
  end
end
