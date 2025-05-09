class PassportCase < Flex::Case
  readonly attribute :passport_id, :string, default: SecureRandom.uuid # always defaults to a new UUID

  attribute :business_process_current_step, :string, default: "collect_application_info"

  after_create :initialize_business_process

  private

  def initialize_business_process
    business_process = PassportApplicationBusinessProcessManager.instance.business_process
    business_process.execute({ case_id: id })
  end
end
