# frozen_string_literal: true

module Strata
  module Cases
    # CaseRowComponent renders a single row in a cases table.
    # It displays case information including ID, creation date, and action links.
    #
    # This component is used by IndexComponent to render individual case rows.
    #
    # @example Basic usage
    #   <%= render CaseRowComponent.new(kase: @case) %>
    #
    class CaseRowComponent < ViewComponent::Base
      def initialize(kase:, path_func: method(:polymorphic_path))
        @case = kase
        @path_func = path_func
      end

      def self.headers
        [
          t(".case_no"),
          t(".assigned_to"),
          t(".step"),
          t(".due_on"),
          t(".created_at")
        ]
      end

      private

      def due_on(kase)
        pending_tasks_with_due_date = kase.tasks.select { |task| task.pending? && task.due_on.present? }
        pending_tasks_with_due_date.map(&:due_on).min&.strftime('%m/%d/%Y')
      end 
    end
  end
end
