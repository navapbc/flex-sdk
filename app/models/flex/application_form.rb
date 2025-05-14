module Flex
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    include Flex::Attributes

    attribute :case_id, :string

    attribute :status, :integer, default: 0
    protected attr_writer :status, :integer
    enum :status, in_progress: 0, submitted: 1

    before_create :create_case, unless: ->(application_form) { application_form.case_id? }
    before_update :prevent_changes_if_submitted, if: :was_submitted?

    def submit_application
      puts "Submitting application with ID: #{id}"
      self[:status] = :submitted
      save!
      publish_event
    end

    protected

    def event_payload
      { id: id }
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

    def publish_event
      puts "Publishing event #{self.class.name}Submitted for application with ID: #{id}"
      EventManager.publish("#{self.class.name}Submitted", self.event_payload)
    end
  end
end
