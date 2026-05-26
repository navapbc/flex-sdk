# frozen_string_literal: true

module Strata
  module US
    # StepIndicatorComponent renders a USWDS step indicator that shows progress
    # through a multi-step process. See https://designsystem.digital.gov/components/step-indicator/.
    #
    # Each step's display name is looked up under `translation_scope` and falls
    # back to a humanized form of the step symbol when no translation exists.
    # Steps before `current_step` are marked complete; the `current_step` is
    # marked current.
    #
    # @example Basic usage
    #   <%= render Strata::US::StepIndicatorComponent.new(
    #         steps: [:personal_info, :review, :submit],
    #         current_step: :review
    #       ) %>
    #
    # @example Counters variant with the header above the segments
    #   <%= render Strata::US::StepIndicatorComponent.new(
    #         steps: [:in_progress, :submitted, :decision_made],
    #         current_step: :submitted,
    #         type: :counters,
    #         large_header: true,
    #         header_first: true
    #       ) %>
    #
    # The `type` option also accepts `:counters_sm`, `:center`, and `:no_labels`,
    # each of which maps to the corresponding `usa-step-indicator--*` modifier.
    class StepIndicatorComponent < ViewComponent::Base
      DEFAULT_TRANSLATION_SCOPE = "strata.application_forms.steps"

      TYPE_CLASSES = {
        counters: "usa-step-indicator--counters",
        counters_sm: "usa-step-indicator--counters-sm",
        center: "usa-step-indicator--center",
        no_labels: "usa-step-indicator--no-labels"
      }.freeze

      def initialize(
        steps:,
        current_step:,
        translation_scope: DEFAULT_TRANSLATION_SCOPE,
        large_header: false,
        header_first: false,
        type: nil,
        classes: nil,
        **html_attributes
      )
        @steps = Array(steps).map(&:to_sym)
        @current_step = current_step.to_sym
        unless @steps.include?(@current_step)
          raise ArgumentError,
                "Invalid current_step: #{@current_step.inspect}. Must be one of #{@steps.inspect}"
        end
        @translation_scope = translation_scope || DEFAULT_TRANSLATION_SCOPE
        @large_header = large_header
        @header_first = header_first
        @type = type
        @classes = classes
        @html_attributes = html_attributes
      end

      def step_indicators
        @step_indicators ||= @steps.map.with_index do |step, index|
          {
            name: t(step.to_s, scope: @translation_scope, default: step.to_s.humanize),
            complete: index < current_step_index,
            current: step == @current_step
          }
        end
      end

      def current_step_index
        @current_step_index ||= @steps.index(@current_step)
      end

      def current_step_name
        step_indicators[current_step_index][:name]
      end

      def total_steps
        @steps.length
      end

      def header_first?
        @header_first
      end

      def wrapper_classes
        class_names(
          "usa-step-indicator",
          TYPE_CLASSES[@type],
          @classes
        )
      end

      def header_classes
        class_names("usa-step-indicator__header", "margin-bottom-2": @header_first)
      end

      def heading_text_classes
        class_names("usa-step-indicator__heading-text", "font-heading-xl": @large_header)
      end

      def segment_classes(step_indicator)
        class_names(
          "usa-step-indicator__segment",
          "usa-step-indicator__segment--complete": step_indicator[:complete],
          "usa-step-indicator__segment--current": step_indicator[:current]
        )
      end

      def root_html_attributes
        attrs = @html_attributes.dup
        attrs.delete(:class)
        attrs[:"aria-label"] = t("strata.components.us.step_indicator.aria_label")
        attrs
      end
    end
  end
end
