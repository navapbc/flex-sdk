module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    include Flex::Attributes

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, in_progress: 0, submitted: 1

    after_create :publish_created
    before_update :prevent_changes_if_submitted, if: :was_submitted?

    def submit_application
      puts "Submitting application with ID: #{id}"
      self[:status] = :submitted
      save!
      publish_submitted
    end

    protected

    def event_payload
      { application_form_id: id }
    end

    protected

    def create_case
      kase = case_class.create!
      self[:case_id] = kase.id
    end

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
