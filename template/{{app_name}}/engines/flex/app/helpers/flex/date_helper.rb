module Flex
  module DateHelper
    def local_en_us(date)
      date.to_formatted_s(:local_en_us)
    end

    def time_since_epoch(date)
      date.to_time.to_i
    end
  end
end