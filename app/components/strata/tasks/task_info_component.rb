# frozen_string_literal: true

module Strata
  module Tasks
    # TaskInfoComponent renders the row of label/value pairs that sits above a
    # task's details section (typically: status, due date, assignee).
    #
    # @example Basic usage
    #   <%= render Strata::Tasks::TaskInfoComponent.new(task_info: [
    #     { label: "Status:",      value: "Pending" },
    #     { label: "Due On:",      value: "07/01/2026" },
    #     { label: "Assigned To:", value: "Jane Doe" }
    #   ]) %>
    class TaskInfoComponent < ViewComponent::Base
      # @param task_info [Array<Hash>] array of +{label:, value:}+ hashes to render.
      def initialize(task_info:)
        @task_info = task_info
      end

      private

      attr_reader :task_info
    end
  end
end
