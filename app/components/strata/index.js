import ConditionalFieldComponentController from "./conditional_field_component_controller"

export { ConditionalFieldComponentController }

// As we add more components with Stimulus, add the Controller to this function to make
// importing easier
export function registerControllers(application) {
  application.register("strata--conditional-field", ConditionalFieldComponentController)
}
