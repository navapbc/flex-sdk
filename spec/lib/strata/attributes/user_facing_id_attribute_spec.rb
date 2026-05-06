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

  it "uses the database default to assign sequence values" do
    first_record = TestRecord.create!
    second_record = TestRecord.create!

    expect(first_record.user_facing_id_sequence).to be_present
    expect(second_record.user_facing_id_sequence).to be > first_record.user_facing_id_sequence
    expect(first_record.user_facing_id).to be_present
    expect(second_record.user_facing_id).not_to eq(first_record.user_facing_id)
  end

  describe "database integration" do
    it "stores the backing value as an integer sequence, not a formatted ID" do
      persisted_record = TestRecord.create!
      raw_sequence_value = TestRecord.connection.select_value(
        "SELECT user_facing_id_sequence FROM test_records WHERE id = #{TestRecord.connection.quote(persisted_record.id)}"
      )

      expect(TestRecord.column_names).to include("user_facing_id_sequence")
      expect(TestRecord.column_names).not_to include("user_facing_id")
      expect(raw_sequence_value).to be_an(Integer)
      expect(raw_sequence_value).to eq(persisted_record.user_facing_id_sequence)
    end

    it "exposes the user-facing ID in the expected format" do
      persisted_record = TestRecord.create!

      expect(persisted_record.user_facing_id).to match(/\AT-[A-HJ-Z]\d{2}-[A-HJ-Z]\d{2}-[A-HJ-Z]\d{2}\z/)
    end

    it "keeps the same user-facing ID after reloading from the database" do
      persisted_record = TestRecord.create!
      formatted_id = persisted_record.user_facing_id

      expect(persisted_record.reload.user_facing_id).to eq(formatted_id)
    end

    it "queries by the backing integer sequence column" do
      persisted_record = TestRecord.create!

      expect(TestRecord.where(user_facing_id: persisted_record.user_facing_id).to_sql).to include(
        "\"test_records\".\"user_facing_id_sequence\""
      )
    end

    it "finds the correct record with native ActiveRecord query methods" do
      matching_record = TestRecord.create!
      other_record = TestRecord.create!

      expect(TestRecord.find_by(user_facing_id: matching_record.user_facing_id)).to eq(matching_record)
      expect(TestRecord.where(user_facing_id: matching_record.user_facing_id)).to contain_exactly(matching_record)
      expect(TestRecord.where(user_facing_id: matching_record.user_facing_id)).not_to include(other_record)
    end

    it "enforces uniqueness at the database layer" do
      TestRecord.create!(user_facing_id_sequence: sequence_value)

      expect do
        TestRecord.create!(user_facing_id_sequence: sequence_value)
      end.to raise_error(ActiveRecord::RecordNotUnique)
    end

    it "finds the correct database record by user-facing ID" do
      matching_record = TestRecord.create!
      other_record = TestRecord.create!

      expect(TestRecord.find_by!(user_facing_id: matching_record.user_facing_id)).to eq(matching_record)
      expect(TestRecord.where(user_facing_id: matching_record.user_facing_id)).to contain_exactly(matching_record)
      expect(TestRecord.where(user_facing_id: matching_record.user_facing_id)).not_to include(other_record)
    end
  end

  describe "with a different prefix" do
    let(:claim_record) { TestRecord.create!(claim_user_facing_id_sequence: sequence_value) }
    let(:claim_user_facing_id) { claim_record.claim_user_facing_id }

    it "formats the user-facing ID with the configured prefix" do
      expect(claim_user_facing_id).to match(/\ACLAIM-[A-HJ-Z]\d{2}-[A-HJ-Z]\d{2}-[A-HJ-Z]\d{2}\z/)
    end

    it "finds the correct record by the prefixed user-facing ID" do
      other_record = TestRecord.create!(claim_user_facing_id_sequence: 54_321)

      expect(TestRecord.find_by!(claim_user_facing_id: claim_user_facing_id)).to eq(claim_record)
      expect(TestRecord.where(claim_user_facing_id: claim_user_facing_id)).to contain_exactly(claim_record)
      expect(TestRecord.where(claim_user_facing_id: claim_user_facing_id)).not_to include(other_record)
    end

    it "finds the correct record with native ActiveRecord query methods" do
      other_record = TestRecord.create!(claim_user_facing_id_sequence: 54_321)

      expect(TestRecord.find_by(claim_user_facing_id: claim_user_facing_id)).to eq(claim_record)
      expect(TestRecord.where(claim_user_facing_id: claim_user_facing_id)).to contain_exactly(claim_record)
      expect(TestRecord.where(claim_user_facing_id: claim_user_facing_id)).not_to include(other_record)
    end

    it "does not allow lookup through an attribute with a different prefix" do
      expect(TestRecord.find_by(user_facing_id: claim_user_facing_id)).to be_nil
      expect(TestRecord.where(user_facing_id: claim_user_facing_id)).to be_empty

      expect do
        TestRecord.find_by!(user_facing_id: claim_user_facing_id)
      end.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it "finds a record by user-facing ID" do
    expect(TestRecord.find_by!(user_facing_id: user_facing_id)).to eq(record)
  end

  it "returns nil from the native non-bang finder for invalid IDs" do
    expect(TestRecord.find_by(user_facing_id: "not-an-id")).to be_nil
  end

  it "finds a record when the user-facing ID input is lowercase" do
    expect(TestRecord.find_by!(user_facing_id: user_facing_id.downcase)).to eq(record)
  end

  it "queries records by user-facing ID with native where" do
    other_record = TestRecord.create!(user_facing_id_sequence: 54_321)

    expect(TestRecord.where(user_facing_id: user_facing_id)).to contain_exactly(record)
    expect(TestRecord.where(user_facing_id: user_facing_id)).not_to include(other_record)
  end

  it "returns an empty relation for invalid IDs" do
    record

    expect(TestRecord.where(user_facing_id: "not-an-id")).to be_empty
  end

  it "raises RecordNotFound for invalid IDs with the native bang finder" do
    expect do
      TestRecord.find_by!(user_facing_id: "not-an-id")
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "handles prefix mismatches consistently across lookup APIs" do
    wrong_prefix_id = user_facing_id.sub(/\AT-/, "X-")

    expect(TestRecord.find_by(user_facing_id: wrong_prefix_id)).to be_nil
    expect(TestRecord.where(user_facing_id: wrong_prefix_id)).to be_empty

    expect do
      TestRecord.find_by!(user_facing_id: wrong_prefix_id)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "raises RecordNotFound for finder parity mismatches" do
    tampered = user_facing_id.sub(/\d\z/) { |digit| ((digit.to_i + 1) % 10).to_s }

    expect do
      TestRecord.find_by!(user_facing_id: tampered)
    end.to raise_error(ActiveRecord::RecordNotFound)
  end
end
