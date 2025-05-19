module Flex
  class TaxId < String
    include Comparable

    TAX_ID_FORMAT = /\A\d{3}-\d{2}-\d{4}\z/

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
