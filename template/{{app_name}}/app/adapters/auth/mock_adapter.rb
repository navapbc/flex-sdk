# frozen_string_literal: true

class Auth::MockAdapter
  def initialize(uid_generator: -> { SecureRandom.uuid })
    @uid_generator = uid_generator
  end

  def self.provider_name
    @@provider_name
  end

  def create_account(email, password)
    if email.include?("UsernameExists")
      raise Auth::Errors::UsernameExists.new
    end

    {
      uid: @uid_generator.call,
      confirmation_channel: "EMAIL",
      provider: "mock"
    }
  end

  def change_email(uid, new_email)
  end

  def forgot_password(email)
    if email.include?("UsernameExists")
      raise Auth::Errors::UsernameExists.new
    end

    {
      confirmation_channel: "EMAIL"
    }
  end

  def confirm_forgot_password(email, code, password)
    if code == "000001"
      raise Auth::Errors::CodeMismatch.new
    end
  end

  def initiate_auth(email, password)
    if email.include?("unconfirmed")
      raise Auth::Errors::UserNotConfirmed.new
    elsif password == "wrong"
      raise Auth::Errors::InvalidCredentials.new
    elsif email.include?("mfa")
      return {
        "challenge_name": "SOFTWARE_TOKEN_MFA",
        "session": "mock-session"
      }
    end

    {
      uid: @uid_generator.call,
      provider: "mock"
    }
  end

  def associate_software_token(access_token)
    "mock-secret"
  end

  def verify_software_token(code, access_token)
    if code == "000001"
      raise Auth::Errors::InvalidSoftwareToken.new
    end
  end

  def disable_software_token(uid)
  end

  def respond_to_auth_challenge(code, challenge)
    if code == "000001"
      raise Auth::Errors::InvalidSoftwareToken.new
    end

    {
      uid: @uid_generator.call,
      provider: "mock"
    }
  end

  def verify_account(email, code)
    if code == "000001"
      raise Auth::Errors::CodeMismatch.new
    end

    {}
  end
end
