module Flex
  # ApplicationForm is the base class for all form models in the Flex SDK.
  # It provides functionality for tracking form status (in_progress/submitted)
  # and prevents modification of submitted forms.
  #
  # Form models should inherit from this class and add their specific fields.
  #
  # @example Creating a form model
  #   class MyApplicationForm < Flex::ApplicationForm
  #     attribute :name, :string
  #     attribute :email, :string
  #   end
  #
  # Key features:
  # - Tracks form status (in_progress/submitted)
  # - Prevents modification of submitted forms
  # - Publishes events when created and submitted
  #
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    include Flex::Attributes

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, in_progress: 0, submitted: 1

    attribute :user_id, :string

    after_create :publish_created
    before_update :prevent_changes_if_submitted, if: :was_submitted?

    # Submits the application form, changing its status to 'submitted'
    # and publishing a submission event.
    #
    # This method should be called when a user submits the form.
    # After submission, the form can no longer be modified.
    #
    # @return [Boolean] True if the submission was successful
    def submit_application
      puts "Submitting application with ID: #{id}"
      self[:status] = :submitted
      self[:submitted_at] = Time.current
      save!
      publish_submitted
    end

    protected

    # Returns the event payload for publishing events related to this form.
    #
    # @return [Hash] Payload with application_form_id
    def event_payload
      payload = { application_form_id: id }
      payload[:submitted_at] = submitted_at if submitted_at.present?
      payload
    end

    protected

    # Creates a case associated with this application form.
    #
    # @return [Flex::Case] The created case
    def create_case
      kase = case_class.create!
      self[:case_id] = kase.id
    end

    # Determines the case class corresponding to this application form class.
    #
    # @return [Class] The case class (ApplicationForm -> Case)
    def case_class
      self.class.name.sub("ApplicationForm", "Case").constantize
    end

    private

    def was_submitted?
      status_was == "submitted"
    end

    def prevent_changes_if_submitted
      errors.add(:base, "Cannot modify a submitted application")
      throw :abort
    end

    def publish_created
      Rails.logger.debug "Publishing event #{self.class.name}Created for application with ID: #{id}"
      Flex::EventManager.publish("#{self.class.name}Created", self.event_payload)
    end

    def publish_submitted
      Rails.logger.debug "Publishing event #{self.class.name}Submitted for application with ID: #{id}"
      Flex::EventManager.publish("#{self.class.name}Submitted", self.event_payload)
    end
  end
end
