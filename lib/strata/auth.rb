# frozen_string_literal: true

require "strata/auth/strategies/base"
require "strata/auth/strategies/hmac"

module Strata
  # Auth is a module that provides authentication functionality for the Strata SDK.
  # It includes the base strategy class and the HMAC strategy class.
  module Auth
    class AuthenticationError < StandardError; end
    class MissingCredentials < AuthenticationError; end
    class InvalidSignature < AuthenticationError; end
  end
end
