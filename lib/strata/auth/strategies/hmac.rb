# frozen_string_literal: true

module Strata
  module Auth
    module Strategies
      # Hmac is a strategy that authenticates requests using a HMAC signature.
      # It verifies the signature of the request body against a secret key.
      class Hmac < Base
        HEADER_FORMAT = /\AHMAC sig=(.+)\z/

        def initialize(secret_key:)
          @secret_key = secret_key
        end

        def authenticate!(request)
          auth_header = request.headers["Authorization"]
          fail_auth!(Strata::Auth::MissingCredentials, "Missing Authorization header") if auth_header.blank?

          match = auth_header.match(HEADER_FORMAT)
          fail_auth!(Strata::Auth::MissingCredentials, "Invalid Authorization header format") unless match

          provided_signature = match[1]
          body = request.body&.read || ""
          expected_signature = sign(body: body)
          request.body&.rewind # Ensure the body can be read again if needed

          unless ActiveSupport::SecurityUtils.secure_compare(provided_signature, expected_signature)
            fail_auth!(Strata::Auth::InvalidSignature, "Signature verification failed")
          end

          true
        end

        private

        def sign(body:)
          Base64.strict_encode64(
            OpenSSL::HMAC.digest("sha256", @secret_key, body)
          )
        end
      end
    end
  end
end
