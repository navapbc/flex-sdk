module Flex
  # Custom form builder. Beyond adding USWDS classes, this also
  # supports setting the label, hint, and error messages by just
  # using the field helpers (i.e text_field, check_box), and adds
  # additional helpers like fieldset and hint.
  # https://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html
  class FormBuilder < ActionView::Helpers::FormBuilder
    standard_helpers = %i[email_field file_field password_field text_area text_field]

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
    standard_helpers.each do |field_type|
      define_method(field_type) do |attribute, options = {}|
        classes = us_class_for_field_type(field_type, options[:width])
        classes += " usa-input--error" if has_error?(attribute)
        append_to_option(options, :class, " #{classes}")

        label_text = options.delete(:label)
        label_class = options.delete(:label_class) || ""
        skip_form_group = options.delete(:skip_form_group)

        label_options = options.except(:width, :class, :id).merge({
          class: label_class,
          for: options[:id]
        })
        field_options = options.except(:label, :hint, :label_class)

        if options[:hint]
          field_options[:aria_describedby] = hint_id(attribute)
        end

        content = us_text_field_label(attribute, label_text, label_options) +
          super(attribute, field_options)

        if skip_form_group
          return content
        end

        form_group(attribute, options[:group_options] || {}) do
          content
        end
      end
    end

    def check_box(attribute, options = {}, *args)
      append_to_option(options, :class, " #{us_class_for_field_type(:check_box)}")

      label_text = options.delete(:label)

      @template.content_tag(:div, class: "usa-checkbox") do
        super(attribute, options, *args) + us_toggle_label("checkbox", attribute, label_text, options)
      end
    end

    def radio_button(attribute, tag_value, options = {})
      append_to_option(options, :class, " #{us_class_for_field_type(:radio_button)}")

      label_text = options.delete(:label)
      label_options = { for: field_id(attribute, tag_value) }.merge(options)

      @template.content_tag(:div, class: "usa-radio") do
        super(attribute, tag_value, options) + us_toggle_label("radio", attribute, label_text, label_options)
      end
    end

    def select(attribute, choices, options = {}, html_options = {})
      append_to_option(html_options, :class, " usa-select")

      label_text = options.delete(:label)
      skip_form_group = options.delete(:skip_form_group)

      content = us_text_field_label(attribute, label_text, options) +
        super(attribute, choices, options, html_options)

      if skip_form_group
        return content
      end

      form_group(attribute) { content }
    end

    def submit(value = nil, options = {})
      append_to_option(options, :class, " usa-button")

      if options[:big]
        append_to_option(options, :class, " usa-button--big margin-y-6")
      end

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

    def tax_id_field(attribute, options = {})
      options[:inputmode] = "numeric"
      options[:placeholder] = "_________"
      options[:width] = "md"

      append_to_option(options, :class, " usa-masked")
      append_to_option(options, :hint, @template.content_tag(:p, I18n.t("flex.form_builder.tax_id_format")))

      text_field(attribute, options)
    end

    def date_picker(attribute, options = {})
      raw_value = object.send(attribute) if object

      append_to_option(options, :hint, @template.content_tag(:p, I18n.t("flex.form_builder.date_picker_format")))

      group_options = options[:group_options] || {}
      append_to_option(group_options, :class, " usa-date-picker")

      if raw_value.is_a?(Date)
        append_to_option(group_options, :"data-default-value", raw_value.strftime("%Y-%m-%d"))
        value = raw_value.strftime("%m/%d/%Y") if raw_value.is_a?(Date)
      end

      text_field(attribute, options.merge(value: value, group_options: group_options))
    end

    def memorable_date(attribute, options = {})
      legend_text = options.delete(:legend) || human_name(attribute)
      hint_text = options.delete(:hint) || I18n.t("flex.form_builder.memorable_date_hint")
      hint_id = "#{attribute}_hint"

      object_value = object&.send(attribute)
      raw_value = object&.send("#{attribute}_before_type_cast") || {}
      month_value = object_value&.month || raw_value[:month] || nil
      day_value = object_value&.day || raw_value[:day] || nil
      year_value = object_value&.year || raw_value[:year] || nil

      month_options = (1..12).map do |m|
        [ Date::MONTHNAMES[m], m ]
      end
      month_options.unshift([ I18n.t("flex.form_builder.select_month"), "" ])

      fieldset(legend_text) do
        @template.content_tag(:span, hint_text, class: "usa-hint", id: hint_id) +
        field_error(attribute) +
        @template.content_tag(:div, class: "usa-memorable-date") do
          fields_for attribute do |date_of_birth_fields|
            # Month select
            @template.content_tag(:div, class: "usa-form-group usa-form-group--month usa-form-group--select") do
              date_of_birth_fields.select(
                "month",
                month_options,
                { label: "Month", skip_form_group: true, selected: month_value },
                {
                  class: "usa-select",
                  "aria-describedby": hint_id
                }
              )
            end +

            # Day input
            @template.content_tag(:div, class: "usa-form-group usa-form-group--day") do
              date_of_birth_fields.text_field(
                "day",
                {
                  label: "Day",
                  skip_form_group: true,
                  type: "number",
                  value: day_value,
                  "aria-describedby": hint_id,
                  maxlength: 2,
                  pattern: "[0-9]*",
                  inputmode: "numeric"
                }
              )
            end +

            # Year input
            @template.content_tag(:div, class: "usa-form-group usa-form-group--year") do
              date_of_birth_fields.text_field(
                "year",
                {
                  label: "Year",
                  skip_form_group: true,
                  type: "number",
                  value: year_value,
                  "aria-describedby": hint_id,
                  minlength: 4,
                  maxlength: 4,
                  pattern: "[0-9]*",
                  inputmode: "numeric"
                }
              )
            end
          end
        end
      end
    end

    def field_error(attribute)
      return unless has_error?(attribute)

      @template.content_tag(:span, object.errors.full_messages_for(attribute).first, class: "usa-error-message")
    end

    def fieldset(legend, options = {}, &block)
      legend_classes = "usa-legend"

      if options[:large_legend]
        legend_classes += " usa-legend--large"
      end

      form_group(options[:attribute]) do
        @template.content_tag(:fieldset, class: "usa-fieldset") do
          @template.content_tag(:legend, legend, class: legend_classes) + @template.capture(&block)
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

    def form_group(attribute = nil, options = {}, &block)
      append_to_option(options, :class, " usa-form-group")
      children = @template.capture(&block)

      if options[:show_error] or (attribute and has_error?(attribute))
        append_to_option(options, :class, " usa-form-group--error")
      end

      @template.content_tag(:div, children, options)
    end

    def yes_no(attribute, options = {})
      yes_options = options[:yes_options] || {}
      no_options = options[:no_options] || {}
      value = if object then object.send(attribute) else nil end

      yes_options = { label: I18n.t("flex.form_builder.boolean_true") }.merge(yes_options)
      no_options = { label: I18n.t("flex.form_builder.boolean_false") }.merge(no_options)

      @template.capture do
        # Hidden field included for same reason as radio button collections (https://api.rubyonrails.org/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_radio_buttons)
        hidden_field(attribute, value: "") +
        fieldset(options[:legend] || human_name(attribute), { attribute: attribute }) do
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

    def append_to_option(options, key, value)
      current_value = options[key] || ""

      if current_value.is_a?(Proc)
        options[key] = -> { current_value.call + value }
      else
        options[key] = current_value + value
      end
    end

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
      hint_option = options.delete(:hint)
      classes = "usa-label"
      for_attr = options[:for] || field_id(attribute)

      if options[:class]
        classes += " #{options[:class]}"
      end

      unless text
        text = human_name(attribute)
      end

      if options[:optional]
        text += @template.content_tag(:span, " (#{I18n.t('flex.form_builder.optional').downcase})", class: "usa-hint")
      end

      if hint_option
        if hint_option.is_a?(Proc)
          hint_content = @template.capture(&hint_option)
        else
          hint_content = @template.raw(hint_option)
        end

        hint = @template.content_tag(:div, hint_content, id: hint_id(attribute), class: "usa-hint")
      end

      label(attribute, @template.raw(text), { class: classes, for: for_attr }) + field_error(attribute) + hint
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

    def hint_id(attribute)
      "#{attribute}_hint"
    end

    def hint_id(attribute)
      "#{attribute}_hint"
    end
  end
end
