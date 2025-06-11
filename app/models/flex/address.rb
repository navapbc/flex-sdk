module Flex
  # Address is a value object representing a physical address with street lines,
  # city, state, and zip code components.
  #
  # This class is used with AddressAttribute to provide structured address handling
  # in form models.
  #
  # @example Creating an address
  #   address = Flex::Address.new("123 Main St", "Apt 4B", "Anytown", "CA", "12345")
  #
  # Key features:
  # - Stores address components (street lines, city, state, zip)
  # - Provides comparison between address objects
  #
  class Address
    include ActiveModel::Model
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
      [ street_line_1, street_line_2, city, state, zip_code ] <=> [ other.street_line_1, other.street_line_2, other.city, other.state, other.zip_code ]
    end
  end
end
