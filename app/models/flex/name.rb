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
  class Name
    include ActiveModel::Model
    include Comparable

    attr_reader :first, :middle, :last

    def initialize(first, middle, last)
      @first = first
      @middle = middle
      @last = last
    end

    def full_name
      [ first, middle, last ].compact.join(" ")
    end

    def <=>(other)
      [ first, middle, last ] <=> [ other.first, other.middle, other.last ]
    end

    def persisted?
      false
    end

    def to_h
      {
        first: first,
        middle: middle,
        last: last
      }
    end

    def self.from_h(h)
      new(*h.fetch_values('first', 'middle', 'last'))
    end
  end
end
