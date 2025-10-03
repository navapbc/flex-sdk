# frozen_string_literal: true

module Strata
  # TaxId is a value object representing a tax identification number (e.g., SSN).
  # It inherits from String but adds formatting capabilities and validation.
  #
  # This class is used with TaxIdAttribute to provide structured tax ID handling
  # in form models.
  #
  # @example Creating a tax ID
  #   tax_id = Strata::TaxId.new("123456789")
  #   puts tax_id.formatted  # => "123-45-6789"
  #
  # Key features:
  # - Stores the raw digits of the tax ID
  # - Formats the tax ID with dashes (XXX-XX-XXXX)
  # - Provides comparison between tax ID objects
  #
  class TaxId < String
    include Comparable

    TAX_ID_FORMAT_NO_DASHES = /\A\d{9}\z/

    def initialize(value)
      # Store only the digits, stripping any non-numeric characters
      super(value.to_s.gsub(/\D/, ""))
    end

    # Returns the Tax ID with dashes in XXX-XX-XXXX format
    def formatted
      if length == 9
        "#{self[0..2]}-#{self[3..4]}-#{self[5..8]}"
      else
        self
      end
    end

    def <=>(other)
      other_tax_id = other.is_a?(TaxId) ? other : TaxId.new(other.to_s)
      super(other_tax_id)
    end
  end
end
