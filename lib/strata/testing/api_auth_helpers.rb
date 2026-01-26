# frozen_string_literal: true

module Strata
  module Testing
    # ApiAuthHelpers is a module that provides helpers for testing API authentication. It is exported for use via the strata gem.
    module ApiAuthHelpers
      def hmac_auth_headers(body:, secret:)
        signature = Base64.strict_encode64(
          OpenSSL::HMAC.digest("sha256", secret, body)
        )
        { "Authorization" => "HMAC sig=#{signature}" }
      end

      def mock_api_request(body:, headers: {})
        env = {
          "rack.input" => StringIO.new(body)
        }

        headers.each do |k, v|
          if k == "Authorization"
            env["HTTP_AUTHORIZATION"] = v
          else
            env["HTTP_#{k.upcase.gsub('-', '_')}"] = v
          end
        end

        ActionDispatch::Request.new(env)
      end
    end
  end
end
