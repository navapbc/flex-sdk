# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Auth::Strategies::Base do
  let(:strategy) { described_class.new }

  describe "#authenticate!" do
    let(:request) { mock_api_request(body: "{}", headers: {}) }

    it "raises NotImplementedError" do
      expect { strategy.authenticate!(request) }.to raise_error(NotImplementedError, "Strata::Auth::Strategies::Base must implement #authenticate!")
    end
  end
end
