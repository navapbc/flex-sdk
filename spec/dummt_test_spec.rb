# spec/dummy_test_spec.rb
require "rails_helper"
include ActionDispatch::TestProcess

RSpec.describe "Dummy Test" do
  it "runs a basic test" do
    expect(1).to eq(1)
  end
end
