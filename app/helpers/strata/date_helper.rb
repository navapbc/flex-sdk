module Strata
  # DateHelper provides view helpers for formatting and manipulating dates.
  # This module is used in views to display dates in consistent formats.
  #
  # @example Formatting a date in US locale
  #   local_en_us(Date.new(2023, 1, 15))  # => "01/15/2023"
  #
  module DateHelper
    def local_en_us(date)
      date&.to_formatted_s(:local_en_us)
    end

    def time_since_epoch(date)
      date&.to_time&.to_i
    end
  end
end
