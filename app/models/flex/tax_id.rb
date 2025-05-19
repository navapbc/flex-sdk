module Flex
  class TaxId < String
    include Comparable

    # Regular expression for validating Tax ID format
    TAX_ID_FORMAT = /\A\d{3}-\d{2}-\d{4}\z/

    def initialize(value)
      # Store only the digits, stripping any non-numeric characters
      @raw_value = value.to_s.gsub(/\D/, "")
      super(@raw_value)
    end

    # Returns the Tax ID with dashes in XXX-XX-XXXX format
    def formatted
      if @raw_value.length == 9
        "#{@raw_value[0..2]}-#{@raw_value[3..4]}-#{@raw_value[5..8]}"
      else
        @raw_value
      end
    end

    def <=>(other)
      other_tax_id = other.is_a?(TaxId) ? other : TaxId.new(other.to_s)
      self <=> other_tax_id
    end
  end
end
