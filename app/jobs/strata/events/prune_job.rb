# frozen_string_literal: true

module Strata
  module Events
    # ActiveJob entry point for scheduled event retention.
    class PruneJob < Strata::ApplicationJob
      def perform(older_than_days: nil, dry_run: false)
        Strata::Events::Pruner.call(older_than_days: older_than_days, dry_run: dry_run)
      end
    end
  end
end
