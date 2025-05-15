class PassportCase < Flex::Case
  readonly attribute :passport_id, :string, default: -> { SecureRandom.uuid } # always defaults to a new UUID

  def business_process
    Flex::BusinessProcess.get_by_name(:passport)
  end
end
