module Flex
  # Name is a value object representing a person's name with first, middle,
  # and last components.
  #
  # This class is used with NameAttribute to provide structured name handling
  # in form models.
  #
  # @example Creating a name
  #   name = Flex::Name.new("John", "A", "Doe")
  #   puts name.full_name  # => "John A Doe"
  #
  # Key features:
  # - Stores first, middle, and last name components
  # - Provides comparison between name objects
  # - Formats full name with appropriate spacing
  #
  class Name < ValueObject
    include Comparable

    attribute :first, :string
    attribute :middle, :string
    attribute :last, :string

    def full_name
      [ first, middle, last ].compact.join(" ")
    end

    def <=>(other)
      [ last, first, middle ] <=> [ other.last, other.first, other.middle ]
    end

    def persisted?
      false
    end
  end
end
