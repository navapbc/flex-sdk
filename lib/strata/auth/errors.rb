# frozen_string_literal: true

module Strata
  module Auth
    class AuthenticationError < StandardError; end
    class MissingCredentials < AuthenticationError; end
    class InvalidSignature < AuthenticationError; end
  end
end
