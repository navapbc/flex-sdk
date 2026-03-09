import { Controller } from "@hotwired/stimulus"

// Conditionally shows/hides form fields based on a radio button's selected value.
//
// Usage:
//   <div data-controller="strata--conditional-field"
//        data-strata--conditional-field-source-value="form_model[field_name]"
//        data-strata--conditional-field-match-value="true"
//        hidden>
//     <!-- conditional content -->
//   </div>
//
// The `source` value is the `name` attribute of the radio button group to observe.
// The `match` value is a comma-separated list of values that make this section visible.
export default class extends Controller {
  static values = {
    source: String,
    match: String,
    clear: { type: Boolean, default: false }
  }

  connect() {
    this.radioButtons = document.querySelectorAll(`input[type="radio"][name="${this.sourceValue}"]`)
    this.boundToggle = this.toggle.bind(this)

    this.radioButtons.forEach((radio) => {
      radio.addEventListener("change", this.boundToggle)
    })

    this.toggle()
  }

  disconnect() {
    this.radioButtons.forEach((radio) => {
      radio.removeEventListener("change", this.boundToggle)
    })
  }

  toggle() {
    const selected = document.querySelector(`input[type="radio"][name="${this.sourceValue}"]:checked`)
    const selectedValue = selected ? selected.value : null
    const matchValues = this.matchValue.split(",")

    if (selectedValue && matchValues.includes(selectedValue)) {
      this.show()
    } else {
      this.hide()
    }
  }

  show() {
    this.element.hidden = false
    this.element.removeAttribute("aria-hidden")
    this.enableInputs()
  }

  hide() {
    this.element.hidden = true
    this.element.setAttribute("aria-hidden", "true")
    this.disableInputs()

    if (this.clearValue) {
      this.clearInputs()
    }
  }

  enableInputs() {
    this.element.querySelectorAll("input, select, textarea").forEach((input) => {
      input.disabled = false
    })
  }

  disableInputs() {
    this.element.querySelectorAll("input, select, textarea").forEach((input) => {
      input.disabled = true
    })
  }

  clearInputs() {
    this.element.querySelectorAll("input, select, textarea").forEach((input) => {
      if (input.type === "radio" || input.type === "checkbox") {
        input.checked = false
      } else {
        input.value = ""
      }
    })
  }
}
