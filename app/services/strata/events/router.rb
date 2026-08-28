# frozen_string_literal: true

module Strata
  module Events
    # Lazily resolves registered handler names and expands an event into one
    # route per handler and target.
    class Router
      Handler = Struct.new(:name, :constant, keyword_init: true)
      Route = Struct.new(:handler, :target_type, :target_id, keyword_init: true)

      def self.handlers_for(event_name)
        Strata::Events.handler_names.filter_map do |handler_name|
          constant = handler_name.safe_constantize
          handler = Handler.new(name: handler_name, constant: constant)
          handler if interested?(handler, event_name)
        end
      end

      def self.routes_for(event)
        handlers_for(event.name).flat_map do |handler|
          targets = targets_for(handler, event.message)
          targets = [ nil ] if targets.empty?

          targets.map do |target|
            Route.new(
              handler: handler.name,
              target_type: target&.class&.base_class&.name,
              target_id: target&.id&.to_s
            )
          end
        end
      end

      class << self
        private

        def interested?(handler, event_name)
          return true unless handler.constant
          return handler.constant.event_names.include?(event_name) if handler.constant.respond_to?(:event_names)
          return handler.constant.handles_event?(event_name) if handler.constant.respond_to?(:handles_event?)

          true
        end

        def targets_for(handler, event)
          return [ nil ] unless handler.constant
          return Array(handler.constant.targets_for_event(event)) if handler.constant.respond_to?(:targets_for_event)

          [ nil ]
        end
      end
    end
  end
end
