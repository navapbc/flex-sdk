require "rails_helper"

RSpec.describe Users::NewSessionForm do
  it "passes validation with valid email and password" do
    form = Users::NewSessionForm.new(
      email: "test@example.com",
      password: "password"
    )

    expect(form).to be_valid
  end

  it "requires email and password" do
    form = Users::NewSessionForm.new({
      email: "",
      password: ""
    })

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:email, :blank)).to be_truthy
    expect(form.errors.of_kind?(:password, :blank)).to be_truthy
  end

  it "requires a valid email" do
    form = Users::NewSessionForm.new(
      email: "not_an_email"
    )

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:email, :invalid)).to be_truthy
  end

  it "requires the honeypot field to be empty" do
    form = Users::NewSessionForm.new(
      email: "test@example.com",
      password: "password",
      spam_trap: "I am a bot"
    )

    expect(form).not_to be_valid
    expect(form.errors.of_kind?(:spam_trap, :present)).to be_truthy
  end
end
