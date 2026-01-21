# frozen_string_literal: true

module Strata
  # ApiAuthenticator is a service that authenticates API requests.
  # It uses a strategy to verify the request.
  #
  # @example
  #   strategy = Strata::Auth::Strategies::Hmac.new(secret_key: ENV['API_SECRET_KEY'])
  #   api_authenticator = Strata::ApiAuthenticator.new(strategy: strategy)
  #   api_authenticator.authenticate!(request)
  #
  class ApiAuthenticator
    attr_reader :strategy

    def initialize(strategy:)
      @strategy = strategy
    end

    def authenticate!(request)
      return true if strategy.authenticate!(request)

      raise Auth::AuthenticationError, "No authentication provided"
    end
  end
end
