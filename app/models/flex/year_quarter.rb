module Flex
  # YearQuarter is a value object representing a year and quarter combination.
  #
  # This class is used with YearQuarterAttribute to provide structured year/quarter
  # handling in form models.
  #
  # @example Creating a year quarter
  #   yq = Flex::YearQuarter.new(year: 2023, quarter:2)
  #   puts "#{yq.year} Q#{yq.quarter}"  # => "2023 Q2"
  #
  # Key features:
  # - Stores year and quarter components
  # - Provides comparison between year quarter objects
  # - Supports arithmetic operations for quarter manipulation
  # - Provides date range functionality via to_date_range method
  #
  class YearQuarter < ValueObject
    include Comparable

    attribute :year, :integer
    attribute :quarter, :integer

    validates :year, presence: true
    validates :quarter, presence: true, numericality: { in: 1..4 }

    def +(other)
      raise TypeError, "Integer expected, got #{other.class}" unless other.is_a?(Integer)

      total_quarters = (year * 4 + (quarter - 1)) + other
      new_year = total_quarters / 4
      new_quarter = (total_quarters % 4) + 1

      self.class.new(year: new_year, quarter: new_quarter)
    end

    def -(other)
      self + (-other)
    end

    def coerce(other)
      if other.is_a?(Integer)
        [ self, other ]
      else
        raise TypeError, "#{self.class} can't be coerced into #{other.class}"
      end
    end

    def to_date_range
      case quarter
      when 1
        DateRange.new(start: USDate.new(year, 1, 1), end: USDate.new(year, 3, 31))
      when 2
        DateRange.new(start: USDate.new(year, 4, 1), end: USDate.new(year, 6, 30))
      when 3
        DateRange.new(start: USDate.new(year, 7, 1), end: USDate.new(year, 9, 30))
      when 4
        DateRange.new(start: USDate.new(year, 10, 1), end: USDate.new(year, 12, 31))
      else
        raise ArgumentError, "Quarter must be 1, 2, 3, or 4"
      end
    end

    # Compares year quarters by time order. Returns:
    # - 0 if self and other are at the same year/quarter
    # - -1 if self is earlier than other
    # - 1 if self is later than other
    # - nil if year quarters aren't comparable (different types or nil values
    # for year or quarter)
    def <=>(other)
      return nil unless other.is_a?(YearQuarter)

      # Return equal (0) if year/quarter arrays match, even if they contain nils.
      # This preserves consistency with ValueObject's == method.
      return 0 if [ year, quarter ] == [ other.year, other.quarter ]

      # Otherwise, nil values make year quarters incomparable
      return nil if year.nil? || quarter.nil? || other.year.nil? || other.quarter.nil?

      [ year, quarter ] <=> [ other.year, other.quarter ]
    end
  end
end
