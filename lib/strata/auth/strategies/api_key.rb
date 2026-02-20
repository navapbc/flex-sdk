# frozen_string_literal: true

module Strata
  module Auth
    module Strategies
      # ApiKey is a strategy that authenticates requests using a static API key.
      # It validates the key from the API-Key header using SHA-256
      # and constant-time comparison to prevent timing attacks.
      class ApiKey < Base
        def initialize(api_key_digest:)
          @api_key_digest = api_key_digest
        end

        def authenticate!(request)
          provided_key = request.headers["API-Key"]
          fail_auth!(Strata::Auth::MissingCredentials, "Missing API-Key header") if provided_key.blank?

          computed = Digest::SHA256.hexdigest(provided_key)

          unless ActiveSupport::SecurityUtils.secure_compare(computed, @api_key_digest)
            fail_auth!(Strata::Auth::InvalidSignature, "Invalid API key")
          end

          true
        end
      end
    end
  end
end
