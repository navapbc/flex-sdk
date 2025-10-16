# frozen_string_literal: true

module Strata
  # Name is a value object representing a person's name with first, middle,
  # last, and suffix components.
  #
  # This class is used with NameAttribute to provide structured name handling
  # in form models.
  #
  # @example Creating a name
  #   name = Strata::Name.new("John", "A", "Doe", "Jr.")
  #   puts name.full_name  # => "John A Doe Jr."
  #
  # Key features:
  # - Stores first, middle, last, and suffix name components
  # - Provides comparison between name objects
  # - Formats full name with appropriate spacing
  #
  class Name < ValueObject
    include Comparable

    attribute :first, :string
    attribute :middle, :string
    attribute :last, :string
    attribute :suffix, :string

    def blank?
      [ first, middle, last, suffix ].all?(&:blank?)
    end

    def empty?
      [ first, middle, last, suffix ].all? { |component| component.nil? || component.empty? }
    end

    def full_name
      [ first, middle, last, suffix ].compact.join(" ")
    end

    def to_s
      full_name
    end

    def persisted?
      false
    end

    def present?
      !blank?
    end

    def <=>(other)
      [ last, first, middle, suffix ] <=> [ other.last, other.first, other.middle, other.suffix ]
    end
  end
end
