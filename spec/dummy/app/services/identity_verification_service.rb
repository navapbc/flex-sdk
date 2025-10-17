# frozen_string_literal: true

class IdentityVerificationService
  def initialize(kase)
    @kase = kase
  end

  def verify_identity
    Strata::EventManager.publish("IdentityVerified", { case_id: @kase.id })
  end
end
