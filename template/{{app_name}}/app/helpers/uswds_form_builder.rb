# Custom form builder. Beyond adding USWDS classes, this also
# supports setting the label, hint, and error messages by just
# using the field helpers (i.e text_field, check_box), and adds
# additional helpers like fieldset and hint.
# https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html
class UswdsFormBuilder < ActionView::Helpers::FormBuilder
  def initialize(*args)
    super
    self.options[:html] ||= {}
    self.options[:html][:class] ||= "usa-form usa-form--large"
  end

  ########################################
  # Override standard helpers
  ########################################

  # Override default text fields to automatically include the label,
  # hint, and error elements
  #
  # Example usage:
  #   <%= f.text_field :foobar, { label: "Custom label text", hint: "Some hint text" } %>
  %i[email_field file_field password_field text_area text_field].each do |field_type|
    define_method(field_type) do |attribute, options = {}|
      classes = us_class_for_field_type(field_type, options[:width])
      classes += " usa-input--error" if has_error?(attribute)

      options[:class] ||= ""
      options[:class].prepend("#{classes} ")

      label_text = options.delete(:label)

      us_form_group(attribute: attribute) do
        us_text_field_label(attribute, label_text, options) + super(attribute, options)
      end
    end
  end

  def check_box(attribute, options = {}, *args)
    options[:class] ||= ""
    options[:class].prepend(us_class_for_field_type(:check_box))

    label_text = options.delete(:label)

    @template.content_tag(:div, class: "usa-checkbox") do
      super(attribute, options, *args) + us_toggle_label("checkbox", attribute, label_text, options)
    end
  end

  def radio_button(attribute, tag_value, options = {})
    options[:class] ||= ""
    options[:class].prepend(us_class_for_field_type(:radio_button))

    label_text = options.delete(:label)
    label_options = { for: field_id(attribute, tag_value) }.merge(options)

    @template.content_tag(:div, class: "usa-radio") do
      super(attribute, tag_value, options) + us_toggle_label("radio", attribute, label_text, label_options)
    end
  end

  def select(attribute, choices, options = {}, html_options = {})
    classes = "usa-select"

    html_options[:class] ||= ""
    html_options[:class].prepend("#{classes} ")

    label_text = options.delete(:label)

    us_form_group(attribute: attribute) do
      us_text_field_label(attribute, label_text, options) + super(attribute, choices, options, html_options)
    end
  end

  def submit(value = nil, options = {})
    options[:class] ||= ""
    options[:class].prepend("usa-button ")

    super(value, options)
  end

  def honeypot_field
    spam_trap_classes = "opacity-0 position-absolute z-bottom top-0 left-0 height-0 width-0"
    label_text = "Do not fill in this field. It is an anti-spam measure."

    @template.content_tag(:div, class: "usa-form-group #{spam_trap_classes}") do
      label(:spam_trap, label_text, { tabindex: -1, class: "usa-label #{spam_trap_classes}" }) +
      @template.text_field(@object_name, :spam_trap, { autocomplete: "false", tabindex: -1, class: "usa-input #{spam_trap_classes}" })
    end
  end

  ########################################
  # Custom helpers
  ########################################

  def field_error(attribute)
    return unless has_error?(attribute)

    @template.content_tag(:span, object.errors[attribute].to_sentence, class: "usa-error-message")
  end

  def fieldset(legend, attribute = nil, &block)
    us_form_group(attribute: attribute) do
      @template.content_tag(:fieldset, class: "usa-fieldset") do
        @template.content_tag(:legend, legend, class: "usa-legend") + @template.capture(&block)
      end
    end
  end

  # Check if a field has a validation error
  def has_error?(attribute)
    return unless object
    object.errors.has_key?(attribute)
  end

  def human_name(attribute)
    return unless object
    object.class.human_attribute_name(attribute)
  end

  def hint(text)
    @template.content_tag(:div, @template.raw(text), class: "usa-hint")
  end

  def yes_no(attribute, options = {})
    yes_options = options[:yes_options] || {}
    no_options = options[:no_options] || {}
    value = if object then object.send(attribute) else nil end

    yes_options = { label: I18n.t("us_form_with.boolean_true") }.merge(yes_options)
    no_options = { label: I18n.t("us_form_with.boolean_false") }.merge(no_options)

    @template.capture do
      # Hidden field included for same reason as radio button collections (https://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_radio_buttons)
      hidden_field(attribute, value: "") +
      fieldset(options[:legend] || human_name(attribute), attribute) do
        buttons =
          radio_button(attribute, true, yes_options) +
          radio_button(attribute, false, no_options)

        if has_error?(attribute)
          field_error(attribute) + buttons
        else
          buttons
        end
      end
    end
  end

  private
    def us_class_for_field_type(field_type, width = nil)
      case field_type
      when :check_box
        "usa-checkbox__input usa-checkbox__input--tile"
      when :file_field
        "usa-file-input"
      when :radio_button
        "usa-radio__input usa-radio__input--tile"
      when :text_area
        "usa-textarea"
      else
        classes = "usa-input"
        classes += " usa-input--#{width}" if width
        classes
      end
    end


    # Render the label, hint text, and error message for a form field
    def us_text_field_label(attribute, text = nil, options = {})
      hint_text = options.delete(:hint)

      if hint_text
        hint_id = "#{attribute}_hint"
        options[:aria_describedby] = hint_id
        hint = @template.content_tag(:div, @template.raw(hint_text), id: hint_id, class: "usa-hint")
      end

      label(attribute, text, { class: "usa-label" }) + hint + field_error(attribute)
    end

    # Label for a checkbox or radio
    def us_toggle_label(type, attribute, text = nil, options = {})
      hint_text = options.delete(:hint)
      label_text = text || object.class.human_attribute_name(attribute)
      options = options.merge({ class: "usa-#{type}__label" })

      if hint_text
        hint = @template.content_tag(:span, hint_text, class: "usa-#{type}__label-description")
        label_text = "#{label_text} #{hint}".html_safe
      end

      label(attribute, label_text, options)
    end

    def us_form_group(attribute: nil, show_error: nil, &block)
      children = @template.capture(&block)
      classes = "usa-form-group"
      classes += " usa-form-group--error" if show_error or (attribute and has_error?(attribute))

      @template.content_tag(:div, children, class: classes)
    end
end
