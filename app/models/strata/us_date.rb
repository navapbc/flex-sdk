module Strata
  # A Date subclass that handles US-format dates (MM/DD/YYYY)
  # @example Creating a US date
  #   USDate.cast("12/25/2023") #=> #<Strata::USDate: 2023-12-25>
  class USDate < Date
    DATE_FORMATS = [
      "%m/%d/%Y",  # US format (when parsing from user)
      "%Y-%m-%d"  # ISO format (when serializing to / deserializing from database)
    ]

    # Attempts to cast a value into a USDate
    # @param value [Date, String, nil] the value to cast
    # @return [USDate, nil] the casted date or nil if invalid
    # @example Cast from string
    #   USDate.cast("12/25/2023") #=> #<Strata::USDate: 2023-12-25>
    # @example Cast from Date
    #   USDate.cast(Date.new(2023, 12, 25)) #=> #<Strata::USDate: 2023-12-25>
    def self.cast(value)
      case value
      when nil
        nil
      when Date
        new(value.year, value.month, value.day)
      when String
        DATE_FORMATS.each do |format|
          begin
            date = Date.strptime(value, format)
            return new(date.year, date.month, date.day)
          rescue Date::Error
            next
          end
        end
        nil  # If all formats fail, return nil
      else
        nil
      end
    end
  end
end
