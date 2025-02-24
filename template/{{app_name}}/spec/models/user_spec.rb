require 'rails_helper'

RSpec.describe User, type: :model do
  describe "access_token" do
    let(:user) { build(:user) }

    it "is an attr_accessor so we can store the token in the session" do
      expect(user).to respond_to(:access_token)
      expect(user).to respond_to(:access_token=)
    end
  end

  describe "access_token_expires_within_minutes?" do
    let(:user) { build(:user) }
    let(:access_token) {
      JWT.encode({ exp: 5.minutes.from_now.to_i }, nil)
    }

    it "returns true if the access token expires within the designated minutes" do
      expect(user.access_token_expires_within_minutes?(access_token, 5)).to eq(true)
    end

    it "returns false if the access token is not expiring within the designated minutes" do
      expect(user.access_token_expires_within_minutes?(access_token, 1)).to eq(false)
    end
  end

  describe "applicant?" do
    let(:user) { build(:user) }

    it "returns true if the user has a applicant role" do
      user.user_role = build(:user_role, :applicant)
      expect(user.applicant?).to eq(true)
    end

    it "returns false if the user does not have a applicant role" do
      user.user_role = build(:user_role, :employer)
      expect(user.applicant?).to eq(false)
    end
  end

  describe "employer?" do
    let(:user) { build(:user) }

    it "returns true if the user has an employer role" do
      user.user_role = build(:user_role, :employer)
      expect(user.employer?).to eq(true)
    end

    it "returns false if the user does not have an employer role" do
      user.user_role = build(:user_role, :applicant)
      expect(user.employer?).to eq(false)
    end
  end

  describe "superadmin?" do
    let(:user) { build(:user) }

    pending "returns true for a superadmin"

    it "returns false for a applicant" do
      user.user_role = build(:user_role, :applicant)
      expect(user.superadmin?).to eq(false)
    end

    it "returns false for an employer" do
      user.user_role = build(:user_role, :employer)
      expect(user.superadmin?).to eq(false)
    end
  end
end
