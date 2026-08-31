# frozen_string_literal: true

module Strata
  module Events
    # Applies an explicit retention policy to terminal event history.
    class Pruner
      Result = Struct.new(
        :cutoff,
        :events,
        :deliveries,
        :duration,
        :dry_run,
        keyword_init: true
      )

      def self.call(older_than_days: nil, dry_run: false)
        days = older_than_days || Strata::Events.config.retention_days
        validate_days!(days)
        cutoff = days.to_i.days.ago
        started_at = monotonic_time
        scope = eligible_events(cutoff)
        ensure_audit_log! unless dry_run

        return dry_run_result(scope, cutoff, started_at) if dry_run

        prune(scope, cutoff, started_at)
      end

      def self.eligible_events(cutoff)
        unfinished_event_ids = Strata::EventDelivery.non_terminal.select(:strata_event_id)
        Strata::Event
          .occurred_before(cutoff)
          .where.not(dispatched_at: nil)
          .where.not(id: unfinished_event_ids)
          .order(:occurred_at, :id)
      end
      private_class_method :eligible_events

      def self.dry_run_result(scope, cutoff, started_at)
        Result.new(
          cutoff: cutoff,
          events: scope.count,
          deliveries: Strata::EventDelivery.where(strata_event_id: scope.select(:id)).count,
          duration: monotonic_time - started_at,
          dry_run: true
        )
      end
      private_class_method :dry_run_result

      def self.prune(scope, cutoff, started_at)
        event_count = 0
        delivery_count = 0
        deadline = started_at + Strata::Events.config.prune_time_budget.to_f

        loop do
          break if monotonic_time >= deadline

          ids = scope.limit(Strata::Events.config.batch_size).pluck(:id)
          break if ids.empty?

          batch_result = prune_batch(ids, cutoff, started_at)
          delivery_count += batch_result.deliveries
          event_count += batch_result.events
        end

        result = Result.new(
          cutoff: cutoff,
          events: event_count,
          deliveries: delivery_count,
          duration: monotonic_time - started_at,
          dry_run: false
        )
        audit(result) if result.events.zero?
        result
      end
      private_class_method :prune

      def self.prune_batch(ids, cutoff, started_at)
        Strata::Event.transaction do
          deliveries = Strata::EventDelivery.where(strata_event_id: ids).delete_all
          events = Strata::Event.where(id: ids).delete_all
          result = Result.new(
            cutoff: cutoff,
            events: events,
            deliveries: deliveries,
            duration: monotonic_time - started_at,
            dry_run: false
          )
          audit(result)
          result
        end
      end
      private_class_method :prune_batch

      def self.audit(result)
        Strata::AuditLog.write!(
          action: "events.pruned",
          data: {
            cutoff: result.cutoff.iso8601,
            events: result.events,
            deliveries: result.deliveries,
            duration_seconds: result.duration
          }
        )
      end
      private_class_method :audit

      def self.ensure_audit_log!
        return if ActiveRecord::Base.connection.data_source_exists?(Strata::AuditLine.table_name)

        raise "Install Strata::AuditLog before pruning events with `bin/rails generate strata:audit_log`"
      end
      private_class_method :ensure_audit_log!

      def self.validate_days!(days)
        number = Integer(days, exception: false)
        raise ArgumentError, "Event retention days must be explicitly configured" unless number&.positive?
      end
      private_class_method :validate_days!

      def self.monotonic_time
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end
      private_class_method :monotonic_time
    end
  end
end
