module Flex
  class Address
    include Comparable

    attr_reader :street_line_1, :street_line_2, :city, :state, :zip_code

    def initialize(street_line_1, street_line_2, city, state, zip_code)
      @street_line_1 = street_line_1
      @street_line_2 = street_line_2
      @city = city
      @state = state
      @zip_code = zip_code
    end

    def <=>(other)
      [street_line_1, street_line_2, city, state, zip_code] <=> [other.street_line_1, other.street_line_2, other.city, other.state, other.zip_code]
    end

    def formatted_address
      parts = [street_line_1]
      parts << street_line_2 if street_line_2.present?
      parts << "#{city}, #{state} #{zip_code}"
      parts.compact.join("\n")
    end
  end
end
