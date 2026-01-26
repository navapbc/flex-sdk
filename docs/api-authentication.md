# API Authentication in Strata SDK

The Strata SDK provides a flexible `ApiAuthenticator` service to secure API endpoints. It currently supports HMAC-based authentication out of the box.

## ApiAuthenticator Overview

The `Strata::ApiAuthenticator` service is a thin wrapper around authentication strategies. It takes a strategy object and uses it to verify incoming `ActionDispatch::Request` objects.

### Initializing the Authenticator

To use the authenticator, you first need to initialize an authentication strategy.

```ruby
# 1. Choose and initialize a strategy
strategy = Strata::Auth::Strategies::Hmac.new(secret_key: ENV['API_SECRET_KEY'])

# 2. Initialize the authenticator with the strategy
authenticator = Strata::ApiAuthenticator.new(strategy: strategy)
```

## HMAC Authentication Strategy

The `Strata::Auth::Strategies::Hmac` strategy authenticates requests by verifying a HMAC signature provided in the `Authorization` header.

### How it Works

1. The client generates a signature of the entire request body using a shared secret key and the SHA256 hashing algorithm.
2. The client sends this signature in the `Authorization` header.
3. The server independently calculates the HMAC signature of the received request body using the same secret key.
4. The server compares the provided signature with the calculated signature using a secure, constant-time comparison.

### Header Format

The HMAC strategy expects the `Authorization` header to follow this format:

```http
Authorization: HMAC sig=<base64_encoded_signature>
```

### Signature Generation (Ruby Example)

If you are calling a Strata-secured API from another Ruby application, you can generate the signature as follows:

```ruby
# openssl and base64 imports necessary if not autoloaded using Rails
# require 'openssl'
# require 'base64'

body = '{"key": "value"}' # The raw request body
secret = 'your-shared-secret'

signature = Base64.strict_encode64(
  OpenSSL::HMAC.digest("sha256", secret, body)
)

headers = { "Authorization" => "HMAC sig=#{signature}" }
```

## Creating a Custom Strategy

You can create your own authentication strategy by inheriting from `Strata::Auth::Strategies::Base` and implementing the `authenticate!` method.

```ruby
class MyCustomStrategy < Strata::Auth::Strategies::Base
  def initialize(api_key:)
    @api_key = api_key
  end

  def authenticate!(request)
    provided_key = request.headers["X-API-KEY"]

    if provided_key.blank?
      fail_auth!(Strata::Auth::MissingCredentials, "Missing X-API-KEY header")
    end

    unless ActiveSupport::SecurityUtils.secure_compare(provided_key, @api_key)
      fail_auth!(Strata::Auth::AuthenticationError, "Invalid API Key")
    end

    true
  end
end
```

### Using the Custom Strategy

Once defined, pass your custom strategy instance into the `ApiAuthenticator`.

```ruby
custom_strategy = MyCustomStrategy.new(api_key: "my-secret-key")
authenticator = Strata::ApiAuthenticator.new(strategy: custom_strategy)

authenticator.authenticate!(request)
```

## Usage in Rails Controllers

The most common way to use `ApiAuthenticator` is within a `before_action` in your controllers.

```ruby
class Api::BaseController < ActionController::API
  before_action :authenticate_request!

  private

  def authenticate_request!
    strategy = Strata::Auth::Strategies::Hmac.new(secret_key: ENV['STRATA_API_SECRET'])
    authenticator = Strata::ApiAuthenticator.new(strategy: strategy)

    begin
      authenticator.authenticate!(request)
    rescue Strata::Auth::AuthenticationError => e
      render json: { error: e.message }, status: :unauthorized
    end
  end
end
```

## Error Handling

The `authenticate!` method will raise one of the following exceptions defined in `Strata::Auth` if authentication fails:

- `Strata::Auth::MissingCredentials`: Raised if the `Authorization` header is missing or improperly formatted.
- `Strata::Auth::InvalidSignature`: Raised if the provided signature does not match the calculated signature.
- `Strata::Auth::AuthenticationError`: The base error class for all authentication failures.

## Testing with ApiAuthHelpers

The Strata SDK includes helpers to simplify testing authenticated API endpoints. These are provided by the `Strata::Testing::ApiAuthHelpers` module.

### Setup in RSpec

You can include the helpers globally in your `rails_helper.rb`:

```ruby
require "strata/testing/api_auth_helpers"

RSpec.configure do |config|
  config.include Strata::Testing::ApiAuthHelpers
end
```

Or include them directly in specific specs:

```ruby
RSpec.describe "My API Endpoint", type: :request do
  include Strata::Testing::ApiAuthHelpers

  let(:secret) { "test-secret" }
  let(:body) { { foo: "bar" }.to_json }

  it "successfully authenticates" do
    headers = hmac_auth_headers(body: body, secret: secret)
    post "/api/my-endpoint", params: body, headers: headers
    
    expect(response).to have_http_status(:ok)
  end
end
```

### Provided Helpers

- `hmac_auth_headers(body:, secret:)`: Returns a hash containing the correctly formatted `Authorization` header for HMAC authentication.
- `mock_api_request(body:, headers: {})`: Creates a mock `ActionDispatch::Request` object for unit testing services that depend on a request.
