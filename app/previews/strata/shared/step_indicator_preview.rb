module Strata
  module Shared
    # StepIndicatorPreview provides preview examples for the step indicator component.
    # It demonstrates different states of the step indicator including in-progress,
    # submitted, and decision-made states.
    #
    # This class is used with Lookbook to generate UI component previews
    # for the step indicator component used in multi-step forms.
    #
    # @example Viewing the submitted state preview
    #   # In Lookbook UI
    #   # Navigate to Strata > StepIndicatorPreview > submitted
    #
    class StepIndicatorPreview < Lookbook::Preview
      layout "component_preview"

      def default
        render template: "strata/shared/_step_indicator", locals: {
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        }
      end

      def counters
        render template: "strata/shared/_step_indicator", locals: {
          type: :counters,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        }
      end

      # @!group Statuses

      def in_progress
        render template: "strata/shared/_step_indicator", locals: {
          type: :counters,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :in_progress
        }
      end

      def submitted
        render template: "strata/shared/_step_indicator", locals: {
          type: :counters,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :submitted
        }
      end

      def decision_made
        render template: "strata/shared/_step_indicator", locals: {
          type: :counters,
          steps: [ :in_progress, :submitted, :decision_made ],
          current_step: :decision_made
        }
      end

      # @!endgroup
    end
  end
end
