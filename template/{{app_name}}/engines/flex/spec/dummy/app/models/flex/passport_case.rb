module Flex
  class PassportCase < Case
    readonly attribute :passport_id, :string, default: SecureRandom.uuid # always defaults to a new UUID

    attribute :business_process_current_step, :string, default: "collect application info"
    private def business_process_current_step=(value)
      self[:business_process_current_step] = value
    end

    @business_process = PassportApplicationBusinessProcessManager.instance.business_process

    def mark_application_info_collected
      self[:business_process_current_step] = "verify identity"
      save!
    end

    def verify_identity
      self[:business_process_current_step] = "review passport photo"
      save!
    end

    def approve
      self[:business_process_current_step] = "end"
      close
    end
  end
end
