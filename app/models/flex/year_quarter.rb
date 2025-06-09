module Flex
  # YearQuarter is a value object representing a year and quarter combination.
  #
  # This class is used with YearQuarterAttribute to provide structured year/quarter
  # handling in form models.
  #
  # @example Creating a year quarter
  #   yq = Flex::YearQuarter.new(2023, 2)
  #   puts "#{yq.year} Q#{yq.quarter}"  # => "2023 Q2"
  #
  # Key features:
  # - Stores year and quarter components
  # - Inherits from Range to provide date range functionality
  # - Provides comparison between year quarter objects
  # - Supports arithmetic operations for quarter manipulation
  # - Immutable value object
  #
  class YearQuarter < Range
    include ActiveModel::Model
    include Comparable

    attr_reader :year, :quarter

    def initialize(year, quarter)
      @year = year
      @quarter = quarter

      start_date, end_date = calculate_date_range(year, quarter)
      Range.instance_method(:initialize).bind(self).call(start_date, end_date)
    end

    def +(other)
      raise TypeError, "Integer expected, got #{other.class}" unless other.is_a?(Integer)

      total_quarters = (@year * 4 + (@quarter - 1)) + other
      new_year = total_quarters / 4
      new_quarter = (total_quarters % 4) + 1

      self.class.new(new_year, new_quarter)
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

    def <=>(other)
      return nil unless other.is_a?(YearQuarter)

      [ year, quarter ] <=> [ other.year, other.quarter ]
    end

    def persisted?
      false
    end

    private

    def calculate_date_range(year, quarter)
      case quarter
      when 1
        [ Date.new(year, 1, 1), Date.new(year, 3, 31) ]
      when 2
        [ Date.new(year, 4, 1), Date.new(year, 6, 30) ]
      when 3
        [ Date.new(year, 7, 1), Date.new(year, 9, 30) ]
      when 4
        [ Date.new(year, 10, 1), Date.new(year, 12, 31) ]
      else
        raise ArgumentError, "Quarter must be 1, 2, 3, or 4"
      end
    end
  end
end
