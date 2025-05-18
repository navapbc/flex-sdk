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

    # Override to_s to return the formatted Tax ID with dashes
    def to_s
      if @raw_value.length == 9
        "#{@raw_value[0..2]}-#{@raw_value[3..4]}-#{@raw_value[5..8]}"
      else
        @raw_value
      end
    end

    def <=>(other)
      to_s <=> other.to_s
    end
  end
end
