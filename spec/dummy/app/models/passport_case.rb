class PassportCase < Flex::Case
  readonly attribute :passport_id, :string, default: -> { SecureRandom.uuid } # always defaults to a new UUID

  def business_process
    PassportApplicationBusinessProcessManager.instance.business_process
  end
end
