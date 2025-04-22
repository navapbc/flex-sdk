module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, in_progress: 0, submitted: 1

    before_update :prevent_changes_if_submitted, if: :was_submitted?

    def submit_application
      self[:status] = :submitted
      save!
      publish_event
    end

    protected

    def event_payload
      { id: id }
    end

    private

    def was_submitted?
      status_was == "submitted"
    end

    def prevent_changes_if_submitted
      errors.add(:base, "Cannot modify a submitted application")
      throw :abort
    end

    def publish_event
      EventManager.publish("#{self.class.name}Submitted", self.event_payload)
    end
  end
end
