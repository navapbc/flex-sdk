module Flex
  class USDate < Date
    def self.cast(value)
      return nil if value.nil?
      return new(value.year, value.month, value.day) if value.is_a?(Date)

      begin
        Date.strptime(value.to_s, '%m/%d/%Y')
      rescue ArgumentError
        nil
      end
    end
  end
end
