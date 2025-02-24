require "rails_helper"

RSpec.describe Users::VerifyAccountForm do
  it "passes validation with valid email and code" do
    form = Users::VerifyAccountForm.new(email: "test@example.com", code: "123456")

    expect(form).to be_valid
  end

  it "requires email and code" do
    form = Users::VerifyAccountForm.new(email: nil, code: nil)

    expect(form).to be_invalid
    expect(form.errors.of_kind?(:email, :blank)).to be_truthy
    expect(form.errors.of_kind?(:code, :blank)).to be_truthy
  end

  it "requires email to be a valid email" do
    form = Users::VerifyAccountForm.new(email: "invalid-email", code: "123456")

    expect(form).to be_invalid
    expect(form.errors.of_kind?(:email, :invalid)).to be_truthy
  end

  it "requires code to be 6 characters" do
    form = Users::VerifyAccountForm.new(email: "test@example.com", code: "12345")

    expect(form).to be_invalid
    expect(form.errors.of_kind?(:code, :wrong_length)).to be_truthy
  end
end
