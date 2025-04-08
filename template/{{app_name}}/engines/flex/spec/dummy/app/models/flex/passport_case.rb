require_relative "../../factories/business_process_simple_factory"
module Flex
  class PassportCase < Case
    readonly attribute :passport_id, :string, default: SecureRandom.uuid # always defaults to a new UUID

    attribute :business_process_current_step, :string, default: "collect application info"
    private def business_process_current_step=(value)
      self[:business_process_current_step] = value
    end

    attribute :is_application_info_collected, :boolean, default: false
    private def is_application_info_collected=(value)
      self[:is_application_info_collected] = value
    end

    attribute :is_passport_photo_reviewed, :boolean, default: false
    private def is_passport_photo_reviewed=(value)
      self[:is_passport_photo_reviewed] = value
    end

    attribute :is_information_verified, :boolean, default: false
    private def is_information_verified=(value)
      self[:is_information_verified] = value
    end

    validates :is_application_info_collected, :is_passport_photo_reviewed, :is_information_verified, inclusion: { in: [ true, false ] }

    readonly @business_process = BusinessProcessSimpleFactory.create_passport_application_business_process

    def mark_application_info_collected
      self[:is_application_info_collected] = true
      self[:business_process_current_step] = "verify identity"
      save!
    end

    def verify_identity
      self[:is_information_verified] = true
      self[:business_process_current_step] = "review passport photo"
      save!
    end

    def approve
      self[:is_passport_photo_reviewed] = true
      self[:business_process_current_step] = "end"
      close
    end

    def open
      self[:status] = :open
      save
    end

    def close
      self[:status] = :closed
      save
    end
  end
end
