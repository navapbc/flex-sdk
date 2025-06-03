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
  # - Provides comparison between year quarter objects
  # - Immutable value object
  #
  class YearQuarter
    include ActiveModel::Model
    include Comparable

    attr_reader :year, :quarter

    def initialize(year, quarter)
      @year = year
      @quarter = quarter
    end

    def <=>(other)
      return nil unless other.is_a?(YearQuarter)
      
      year_comparison = year <=> other.year
      return year_comparison unless year_comparison == 0
      
      quarter <=> other.quarter
    end

    def persisted?
      false
    end
  end
end
