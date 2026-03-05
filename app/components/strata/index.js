import ConditionalFieldComponentController from "./conditional_field_component_controller"

export { ConditionalFieldComponentController }

export function registerControllers(application) {
  application.register("strata--conditional-field", ConditionalFieldComponentController)
}
