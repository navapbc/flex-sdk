module Flex
  # A Date subclass that handles US-format dates (MM/DD/YYYY)
  # @example Creating a US date
  #   USDate.cast("12/25/2023") #=> #<Flex::USDate: 2023-12-25>
  class USDate < Date
    # Attempts to cast a value into a USDate
    # @param value [Date, String, nil] the value to cast
    # @return [USDate, nil] the casted date or nil if invalid
    # @example Cast from string
    #   USDate.cast("12/25/2023") #=> #<Flex::USDate: 2023-12-25>
    # @example Cast from Date
    #   USDate.cast(Date.new(2023, 12, 25)) #=> #<Flex::USDate: 2023-12-25>
    def self.cast(value)
      return nil if value.nil?
      return new(value.year, value.month, value.day) if value.is_a?(Date)

      begin
        Date.strptime(value.to_s, "%m/%d/%Y")
      rescue ArgumentError
        nil
      end
    end
  end
end
