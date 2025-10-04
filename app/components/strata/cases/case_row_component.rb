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

      def self.columns
        [
          :case_no,
          :assigned_to,
          :step,
          :due_on,
          :created_at
        ]
      end

      def self.headers
        self.columns.map { |column| t(".#{column}") }
      end

      protected

      def case_no
        link_to @case.id, @path_func.call(@case)
      end

      def assigned_to
      end

      def step
        @case.business_process_instance.current_step
      end

      def due_on
        pending_tasks_with_due_date = @case.tasks.select { |task| task.pending? && task.due_on.present? }
        pending_tasks_with_due_date.map(&:due_on).min&.strftime("%m/%d/%Y")
      end

      def created_at
        @case.created_at.strftime('%m/%d/%Y')
      end
    end
  end
end
