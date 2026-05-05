# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Attributes::UserFacingIdAttribute do
  let(:sequence_value) { 12_345 }
  let(:record) { TestRecord.create!(user_facing_id_sequence: sequence_value) }
  let(:user_facing_id) { record.user_facing_id }

  it "returns nil when the sequence column is nil" do
    expect(TestRecord.new.user_facing_id).to be_nil
  end

  it "formats the sequence column as a user-facing ID" do
    expect(record.user_facing_id).to eq(user_facing_id)
  end

  it "finds a record by user-facing ID" do
    expect(TestRecord.find_by_user_facing_id!(user_facing_id)).to eq(record)
  end

  it "returns nil from the non-bang finder for invalid IDs" do
    expect(TestRecord.find_by_user_facing_id("not-an-id")).to be_nil
  end

  it "scopes records by user-facing ID" do
    other_record = TestRecord.create!(user_facing_id_sequence: 54_321)

    expect(TestRecord.with_user_facing_id(user_facing_id)).to contain_exactly(record)
    expect(TestRecord.with_user_facing_id(user_facing_id)).not_to include(other_record)
  end

  it "returns an empty scope for invalid IDs" do
    record

    expect(TestRecord.with_user_facing_id("not-an-id")).to be_empty
  end

  it "raises ArgumentError for invalid finder format" do
    expect do
      TestRecord.find_by_user_facing_id!("not-an-id")
    end.to raise_error(ArgumentError)
  end

  it "raises RecordNotFound for finder parity mismatches" do
    tampered = user_facing_id.sub(/\d\z/) { |digit| ((digit.to_i + 1) % 10).to_s }

    expect do
      TestRecord.find_by_user_facing_id!(tampered)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
