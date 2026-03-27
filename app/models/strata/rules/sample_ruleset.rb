# frozen_string_literal: true

module Strata
  module Rules
    # Sample ruleset demonstrating how to implement eligibility rules using the Strata Rules Engine.
    # Includes checks for submission timing, earnings requirements, and benefit calculations.
    class SampleRuleset
      def submitted_within_60_days_of_start_date(submitted_at, start_date)
        return nil if submitted_at.nil? || start_date.nil?

        sixty_days_before_start = start_date.to_time.utc.beginning_of_day - 60.days
        submitted_at >= sixty_days_before_start
      end

      def earned_enough_over_last_four_completed_calendar_quarters(quarterly_earnings, submitted_at)
        return nil if quarterly_earnings.nil? || quarterly_earnings.empty? || submitted_at.nil?

        # Filter quarterly earnings to only include the last four completed quarters (from submission time)
        # Calculate total earnings over the last four quarters
        # Round to nearest hundred dollars
        # Check if total earnings meet the threshold

        # TODO implement
        false
      end

      def earned_at_least_30_times_weekly_benefit_amount(quarterly_earnings, weekly_benefit_amount)
        return nil if quarterly_earnings.nil? || weekly_benefit_amount.nil?

        # TODO implement
        false
      end

      def base_period
        # A base period is the last 4 quarters you completed and were paid
        # prior to the start of your benefit year
        # TODO implement
        nil
      end

      def individual_average_weekly_wage
      end
    end
  end
end
