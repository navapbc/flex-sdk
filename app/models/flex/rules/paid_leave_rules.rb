module Flex
  module Rules
    class PaidLeaveRules < Base
      def submitted_within_60_days_of_leave_start(submitted_at, leave_starts_on)
        return nil if submitted_at.nil? || leave_starts_on.nil?

        sixty_days_before_leave_start = leave_starts_on.to_time.utc.beginning_of_day - 60.days
        submitted_at >= sixty_days_before_leave_start
      end
    end
  end
end
