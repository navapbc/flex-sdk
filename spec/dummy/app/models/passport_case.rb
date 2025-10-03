# frozen_string_literal: true

class PassportCase < Strata::Case
  readonly attribute :passport_id, :uuid, default: -> { SecureRandom.uuid } # always defaults to a new UUID
end
