# frozen_string_literal: true

module Strata
  module US
    # StepIndicatorComponentPreview provides preview examples for
    # Strata::US::StepIndicatorComponent. It demonstrates the default and
    # counters variants and the three application_form statuses (in-progress,
    # submitted, decision-made), plus the large-header / header-first layout.
    #
    # This class is used with Lookbook to generate UI component previews.
    #
    # @example Viewing the submitted state preview
    #   # In Lookbook UI
    #   # Navigate to Strata > US > StepIndicatorComponent > submitted
    class StepIndicatorComponentPreview < Lookbook::Preview
      layout "strata/component_preview"

      def default
        render Strata::US::StepIndicatorComponent.new(
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        )
      end

      def counters
        render Strata::US::StepIndicatorComponent.new(
          type: :counters,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        )
      end

      def counters_sm
        render Strata::US::StepIndicatorComponent.new(
          type: :counters_sm,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        )
      end

      def center
        render Strata::US::StepIndicatorComponent.new(
          type: :center,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        )
      end

      def no_labels
        render Strata::US::StepIndicatorComponent.new(
          type: :no_labels,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        )
      end

      # @!group Statuses

      def in_progress
        render Strata::US::StepIndicatorComponent.new(
          type: :counters,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :in_progress
        )
      end

      def submitted
        render Strata::US::StepIndicatorComponent.new(
          type: :counters,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        )
      end

      def decision_made
        render Strata::US::StepIndicatorComponent.new(
          type: :counters,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :decision_made
        )
      end

      # @!endgroup

      def large_header_first
        render Strata::US::StepIndicatorComponent.new(
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted,
          large_header: true,
          header_first: true
        )
      end
    end
  end
end
