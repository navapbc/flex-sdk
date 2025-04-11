require_relative "../../../../../app/models/flex/application_form"

module Flex
  class PassportApplicationForm < ApplicationForm
    before_create :create_passport_case, unless: -> { has_case_id? }

    attribute :first_name, :string
    attribute :last_name, :string
    attribute :date_of_birth, :date

    attribute :case_id, :integer
    private def case_id=(value)
      self[:case_id] = value
    end

    def has_all_necessary_fields?
      !first_name.nil? && !last_name.nil? && !date_of_birth.nil?
    end

    def submit_application
      if has_all_necessary_fields?
        super
        # this is temporary and will be changed in another PR when implementing an event-based approach
        PassportCase.find(case_id).mark_application_info_collected
      end

      EventsManager.publish("passport_application_submitted", self) if has_all_necessary_fields?
    end

    protected

    def event_payload
      parent_payload = super
      parent_payload.merge({ case_id: case_id })
    end

    private

    def has_case_id?
      !case_id.nil?
    end

    def create_passport_case
      kase = PassportCase.create
      self.case_id = kase.id
    end
  end
end
