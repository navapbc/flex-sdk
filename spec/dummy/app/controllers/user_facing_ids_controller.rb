# frozen_string_literal: true

class UserFacingIdsController < ApplicationController
  SAMPLE_RECORD_COUNT = 8

  def index
    create_sample_records if TestRecord.count < SAMPLE_RECORD_COUNT

    @test_records = TestRecord
      .order(:user_facing_id_sequence)
      .limit(SAMPLE_RECORD_COUNT)
  end

  private

  def create_sample_records
    (SAMPLE_RECORD_COUNT - TestRecord.count).times { TestRecord.create! }
  end
end
