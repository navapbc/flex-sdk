# frozen_string_literal: true

module Strata
  module UserFacingId
    # Raised when a user-facing ID does not match the expected format.
    class FormatError < ArgumentError; end
  end
end
