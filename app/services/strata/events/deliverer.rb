# frozen_string_literal: true

module Strata
  module Events
    # Executes one delivery atomically with its database-backed side effects.
    class Deliverer
      def self.call(delivery)
        return delivery if delivery.terminal?
        return delivery if delivery.failed? && delivery.next_attempt_at&.future?

        deliver(delivery)
      rescue StandardError => error
        record_failure(delivery, error)
        report(error, delivery)
        raise
      end

      def self.deliver(delivery)
        Strata::EventDelivery.transaction do
          delivery.lock!
          return delivery if delivery.terminal?
          return delivery if delivery.failed? && delivery.next_attempt_at&.future?

          event = delivery.event
          result = Strata::Events.with_current_event(event, delivery: delivery) do
            invoke_handler(delivery, event.message)
          end

          delivery.update!(
            status: normalize_result(result),
            attempts: delivery.attempts + 1,
            next_attempt_at: nil,
            last_error: nil
          )
        end
        delivery
      end
      private_class_method :deliver

      def self.invoke_handler(delivery, event)
        handler = delivery.handler.safe_constantize
        raise NameError, "Event handler #{delivery.handler} is not defined" unless handler

        target = load_target(delivery)
        if handler.is_a?(Class) && handler <= Strata::BusinessProcess
          return handler.handle_event(event, target: target)
        end

        invoke_generic_handler(handler, event, target)
      end
      private_class_method :invoke_handler

      def self.load_target(delivery)
        return nil if delivery.target_type.blank? || delivery.target_id.blank?

        target_class = delivery.target_type.safe_constantize
        raise NameError, "Event target type #{delivery.target_type} is not defined" unless target_class

        target_class.unscoped.find(delivery.target_id)
      end
      private_class_method :load_target

      def self.invoke_generic_handler(handler, event, target)
        callable = if handler.respond_to?(:handle_event)
          handler.method(:handle_event)
        elsif handler.respond_to?(:call)
          handler.method(:call)
        elsif handler.instance_methods(false).include?(:handle_event)
          handler.new.method(:handle_event)
        else
          raise NoMethodError, "#{handler.name} must implement handle_event or call"
        end

        target ? callable.call(event, target: target) : callable.call(event)
      end
      private_class_method :invoke_generic_handler

      def self.normalize_result(result)
        result = result.to_sym if result.respond_to?(:to_sym)
        return result if Strata::EventDelivery.statuses.key?(result.to_s) && result != :failed && result != :dead_letter

        :handled
      end
      private_class_method :normalize_result

      def self.record_failure(delivery, error)
        delivery.with_lock do
          attempts = delivery.attempts + 1
          exhausted = attempts >= Strata::Events.config.max_attempts
          delivery.update!(
            status: exhausted ? :dead_letter : :failed,
            attempts: attempts,
            next_attempt_at: exhausted ? nil : retry_at(attempts),
            last_error: error_description(error)
          )
        end
      rescue ActiveRecord::RecordNotFound
        Rails.logger.error("Could not record failure for deleted event delivery #{delivery.id}")
      end
      private_class_method :record_failure

      def self.retry_at(attempts)
        Time.current + (Strata::Events.config.retry_base_delay * (2**(attempts - 1)))
      end
      private_class_method :retry_at

      def self.error_description(error)
        ([ "#{error.class}: #{error.message}" ] + Array(error.backtrace)).join("\n")
      end
      private_class_method :error_description

      def self.report(error, delivery)
        Rails.error.report(
          error,
          handled: false,
          context: {
            strata_event_id: delivery.strata_event_id,
            strata_event_delivery_id: delivery.id,
            handler: delivery.handler
          }
        )
      rescue StandardError => reporting_error
        Rails.logger.error("Unable to report event delivery failure: #{reporting_error.message}")
      end
      private_class_method :report
    end
  end
end
