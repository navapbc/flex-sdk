class FlexStepIndicatorPreview < Lookbook::Preview
  layout "component_preview"

  def in_progress
    render template: "flex/shared/_step_indicator", locals: {
      steps: [:in_progress, :submitted, :decision_made],
      current_step: :in_progress
    }
  end

  def submitted_state
    render template: "flex/shared/_step_indicator", locals: {
      steps: [:in_progress, :submitted, :decision_made],
      current_step: :submitted
    }
  end

  def decision_made_state
    render template: "flex/shared/_step_indicator", locals: {
      steps: [:in_progress, :submitted, :decision_made],
      current_step: :decision_made
    }
  end
end
