module Flex
  module Rules
    class PaidLeaveRules
      def submitted_within_60_days_of_leave_start(submitted_at, leave_starts_on)
        return nil if submitted_at.nil? || leave_starts_on.nil?

        sixty_days_before_leave_start = leave_starts_on.to_time.utc.beginning_of_day - 60.days
        submitted_at >= sixty_days_before_leave_start
      end

      def earned_enough_over_last_four_completed_calendar_quarters(quarterly_earnings, submitted_at)
        return nil if quarterly_earnings.nil? || quarterly_earnings.empty? || submitted_at.nil?

        # Filter quarterly earnings to only include the last four completed quarters (from submission time)
        # Calculate total earnings over the last four quarters
        # Round to nearest hundred dollars
        # Check if total earnings meet the threshold
        # total_earnings_rounded >= 6300

        # To check if you’re eligible, DFML uses all of your earnings from all
        # the jobs and employers you have during your base period. If you have
        # more than one job and are approved for benefits, your benefit amount
        # will be based on the earnings you have received from the employer or
        # employers you are taking leave from.

        # TODO implement
        false
      end

      def earned_at_least_30_times_weekly_benefit_amount(quarterly_earnings, weekly_benefit_amount)
        return nil if quarterly_earnings.nil? || weekly_benefit_amount.nil?

        # TODO implement
        false
      end

      def base_period()
        # A base period is the last 4 quarters you completed and were paid
        # prior to the start of your benefit year
        # TODO implement
        nil
      end

      def individual_average_weekly_wage()
      end
    end
  end
end
