class FlexStepIndicatorPreview < Lookbook::Preview
  layout "component_preview"

  # @!group Statuses

  def in_progress
    render template: "flex/shared/_step_indicator", locals: {
      steps: [ :in_progress, :submitted, :decision_made ],
      current_step: :in_progress
    }
  end

  def submitted
    render template: "flex/shared/_step_indicator", locals: {
      steps: [ :in_progress, :submitted, :decision_made ],
      current_step: :submitted
    }
  end

  def decision_made
    render template: "flex/shared/_step_indicator", locals: {
      steps: [ :in_progress, :submitted, :decision_made ],
      current_step: :decision_made
    }
  end

  # @!endgroup
end
