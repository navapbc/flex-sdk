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
  class Address < ValueObject
    attribute :street_line_1, :string
    attribute :street_line_2, :string
    attribute :city, :string
    attribute :state, :string
    attribute :zip_code, :string

    validates :street_line_1, presence: true
    validates :city, presence: true
    validates :state, presence: true, length: { is: 2 }
    validates :zip_code, presence: true, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be a valid US zip code" }

    def to_s
      [ street_line_1, street_line_2, "#{city}, #{state} #{zip_code}" ].reject(&:blank?).join(", ")
    end
  end
end
