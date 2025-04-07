require_relative "../../factories/business_process_simple_factory"
module Flex
  class PassportCase < Case
    belongs_to :passport_application_form, class_name: 'Flex::PassportApplicationForm'

    readonly attribute :passport_id, :string, default: SecureRandom.uuid # always defaults to a new UUID
    attribute :business_process_current_step, :string, default: "collect application info"

    readonly @business_process = BusinessProcessSimpleFactory::create_passport_application_business_process
  
    def verify_identity
      update!(business_process_current_step: "review passport photo")
    end

    def approve
      update!(business_process_current_step: "end")
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
