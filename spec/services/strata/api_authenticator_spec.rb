# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::ApiAuthenticator do
  let(:strategy) { instance_double(Strata::Auth::Strategies::Base) }
  let(:service) { described_class.new(strategy: strategy) }
  let(:request) { instance_double(ActionDispatch::Request) }

  describe "#authenticate!" do
    it "delegates authentication to the strategy" do
      allow(strategy).to receive(:authenticate!).with(request).and_return(true)
      expect(service.authenticate!(request)).to be true
    end

    context "when strategy returns false" do
      it "raises AuthenticationError" do
        allow(strategy).to receive(:authenticate!).with(request).and_return(false)
        expect { service.authenticate!(request) }.to raise_error(Strata::Auth::AuthenticationError, "No authentication provided")
      end
    end

    context "when strategy raises an error" do
      it "propagates MissingCredentials error" do
        allow(strategy).to receive(:authenticate!).with(request).and_raise(Strata::Auth::MissingCredentials, "Missing header")
        expect { service.authenticate!(request) }.to raise_error(Strata::Auth::MissingCredentials, "Missing header")
      end

      it "propagates InvalidSignature error" do
        allow(strategy).to receive(:authenticate!).with(request).and_raise(Strata::Auth::InvalidSignature, "Invalid signature")
        expect { service.authenticate!(request) }.to raise_error(Strata::Auth::InvalidSignature, "Invalid signature")
      end
    end
  end
end
