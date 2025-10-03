# frozen_string_literal: true

module Strata
  # Name is a value object representing a person's name with first, middle,
  # and last components.
  #
  # This class is used with NameAttribute to provide structured name handling
  # in form models.
  #
  # @example Creating a name
  #   name = Strata::Name.new("John", "A", "Doe")
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

    def blank?
      [ first, middle, last ].all?(&:blank?)
    end

    def empty?
      [ first, middle, last ].all? { |component| component.nil? || component.empty? }
    end

    def full_name
      [ first, middle, last ].compact.join(" ")
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
      [ last, first, middle ] <=> [ other.last, other.first, other.middle ]
    end
  end
end
