# frozen_string_literal: true

module Strata
  # YearMonth is a value object representing a year and month combination.
  #
  # This class is used with YearMonthAttribute to provide structured year/month
  # handling in form models.
  #
  # @example Creating a year month
  #   ym = Strata::YearMonth.new(year: 2023, month: 6)
  #   puts "#{ym.year}-#{ym.month.to_s.rjust(2, '0')}"  # => "2023-06"
  #
  # Key features:
  # - Stores year and month components
  # - Provides comparison between year month objects
  # - Supports arithmetic operations for month manipulation
  # - Provides date range functionality via to_date_range method
  #
  class YearMonth < ValueObject
    include Comparable

    attribute :year, :integer
    attribute :month, :integer

    validates :year, presence: true
    validates :month, presence: true, numericality: { in: 1..12 }

    def +(other)
      raise TypeError, "Integer expected, got #{other.class}" unless other.is_a?(Integer)

      total_months = (year * 12 + (month - 1)) + other
      new_year = total_months / 12
      new_month = (total_months % 12) + 1

      self.class.new(year: new_year, month: new_month)
    end

    def -(other)
      self + (-other)
    end

    def coerce(other)
      [ self, other ]
    end

    def to_date_range
      first_day = USDate.new(year, month, 1)
      last_day = case month
      when 4, 6, 9, 11
                   USDate.new(year, month, 30)
      when 2
                   if Date.leap?(year)
                     USDate.new(year, month, 29)
                   else
                     USDate.new(year, month, 28)
                   end
      else
                   USDate.new(year, month, 31)
      end
      Strata::DateRange.new(start: first_day, end: last_day)
    end

    def to_s
      "#{year}-#{month.to_s.rjust(2, '0')}"
    end

    # Compares year months by time order. Returns:
    # - 0 if self and other are at the same year/month
    # - -1 if self is earlier than other
    # - 1 if self is later than other
    # - nil if year months aren't comparable (different types or nil values
    # for year or month)
    def <=>(other)
      return nil unless other.is_a?(YearMonth)

      # Return equal (0) if year/month arrays match, even if they contain nils.
      # This preserves consistency with ValueObject's == method.
      return 0 if [ year, month ] == [ other.year, other.month ]

      # Otherwise, nil values make year months incomparable
      return nil if year.nil? || month.nil? || other.year.nil? || other.month.nil?

      [ year, month ] <=> [ other.year, other.month ]
    end
  end
end
