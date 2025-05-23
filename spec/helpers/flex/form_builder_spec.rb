require 'rails_helper'

RSpec.describe Flex::FormBuilder do
  before do
    test_form_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes
      include Flex::Attributes

      attribute :first_name, :string
      attribute :start_date, :date  # for date_picker
    end

    stub_const("TestForm", test_form_class)
  end


  let(:template) { ActionView::Base.empty }
  let(:object) { TestForm.new }
  let(:builder) { described_class.new(:object, object, template, {}) }

  describe '#text_field' do
    let(:result) { builder.text_field(:first_name, label: 'Name') }

    it 'outputs a text input' do
      expect(result).to have_element(:input, type: 'text', class: 'usa-input', name: 'object[first_name]')
      expect(result).not_to have_css('.usa-form-group--error')
      expect(result).not_to have_css('.usa-error-message')
    end

    it 'outputs a label' do
      expect(result).to have_element(:label, class: 'usa-label', for: 'object_first_name')
    end

    context 'with id option' do
      let(:result) { builder.text_field(:first_name, id: 'custom-id') }

      it 'outputs a label associated with the input with the custom id' do
        expect(result).to have_element(:input, id: 'custom-id')
        expect(result).to have_element(:label, for: 'custom-id')
      end
    end

    context 'with label option' do
      let(:result) { builder.text_field(:first_name, label: 'Custom label') }

      it 'outputs a label' do
        expect(result).to have_element(:label, text: 'Custom label', class: 'usa-label')
      end
    end

    context 'with hint' do
      let(:result) { builder.text_field(:first_name, hint: 'Enter your name') }

      it 'outputs a hint' do
        expect(result).to have_element(:div, text: 'Enter your name', class: 'usa-hint')
      end

      it 'adds aria-describedby to the input' do
        expect(result).to have_element(:input, aria_describedby: 'first_name_hint')
      end
    end

    context 'with errors' do
      let(:result) { builder.text_field(:first_name) }

      before do
        object.errors.add(:first_name, 'is invalid')
      end

      it 'outputs an error message' do
        expect(result).to have_element(:div, class: 'usa-form-group--error')
        expect(result).to have_element(:span, text: 'is invalid', class: 'usa-error-message')
      end
    end

    context 'with width' do
      let(:result) { builder.text_field(:first_name, width: 'md') }

      it 'adds a width class' do
        expect(result).to have_element(:input, class: 'usa-input usa-input--md')
      end
    end

    context 'with optional set to true' do
      let(:result) { builder.text_field(:first_name, label: 'Name', optional: true) }

      it 'outputs an optional label' do
        expect(result).to have_element(:label, text: 'Name (optional)')
      end
    end

    context 'with custom class' do
      let(:result) { builder.text_field(:first_name, class: 'custom-class') }

      it 'adds the class to the input' do
        expect(result).to have_element(:input, class: 'custom-class usa-input')
      end
    end

    context 'with label_class' do
      let(:result) { builder.text_field(:first_name, label_class: 'custom-label-class') }

      it 'adds the class to the label' do
        expect(result).to have_element(:label, class: 'usa-label custom-label-class')
      end
    end
  end

  describe '#hint' do
    let(:result) { builder.hint('Enter your name') }

    it 'outputs a hint' do
      expect(result).to have_element(:div, text: 'Enter your name', class: 'usa-hint')
    end
  end

  describe '#date_picker' do
    let(:result) { builder.date_picker(:start_date) }
    let(:object) { TestForm.new(start_date: Date.new(2024, 1, 31)) }

    it 'wraps the input with a date picker class' do
      expect(result).to have_element(:div, class: 'usa-date-picker usa-form-group')
    end

    it 'includes example format in the hint' do
      expect(result).to have_element(:p, text: "Format: mm/dd/yyyy")
    end

    it 'adds USWDS attributes for showing the current value' do
      expect(result).to have_element(:input, value: '01/31/2024')
      expect(result).to have_element(:div, class: 'usa-date-picker', "data-default-value": '2024-01-31')
    end

    context 'when no existing date value' do
      let(:object) { TestForm.new(start_date: nil) }

      it 'does not set a value' do
        expect(result).to have_element(:input, value: nil)
        expect(result).to have_element(:div, class: 'usa-date-picker', "data-default-value": nil)
      end
    end
  end

  describe '#fieldset' do
    let(:result) { builder.fieldset('Legend') { 'Fieldset content' } }

    it 'outputs a fieldset' do
      expect(result).to have_element(:fieldset, class: 'usa-fieldset')
    end

    it 'outputs a legend' do
      expect(result).to have_element(:legend, text: 'Legend', class: 'usa-legend')
    end

    it 'outputs the content within the block' do
      expect(result).to have_text('Fieldset content')
    end

    context 'with large_legend set to true' do
      let(:result) { builder.fieldset('Legend', large_legend: true) { 'Fieldset content' } }

      it 'outputs a large legend' do
        expect(result).to have_element(:legend, class: 'usa-legend usa-legend--large')
      end
    end
  end

  describe '#select' do
    let(:result) { builder.select(:first_name, [ 'Option 1', 'Option 2' ]) }

    it 'outputs a select field' do
      expect(result).to have_element(:select, class: 'usa-select', name: 'object[first_name]')
    end

    context 'with label' do
      let(:result) { builder.select(:first_name, [ 'Option 1', 'Option 2' ], label: 'Custom label') }

      it 'outputs a label' do
        expect(result).to have_element(:label, text: 'Custom label', class: 'usa-label')
      end
    end
  end

  describe '#submit' do
    let (:result) { builder.submit() }

    it 'outputs a submit button' do
      expect(result).to have_element(:input, type: 'submit', class: 'usa-button')
    end

    context 'with big set to true' do
      let (:result) { builder.submit(nil, { big: true }) }

      it 'outputs a big submit button' do
        expect(result).to have_element(:input, type: 'submit', class: 'usa-button--big')
      end
    end
  end

  describe '#check_box' do
    let(:result) { builder.check_box(:first_name) }

    it 'outputs a check box' do
      expect(result).to have_element(:div, class: 'usa-checkbox')
      expect(result).to have_element(:input, type: 'checkbox', class: 'usa-checkbox__input', name: 'object[first_name]')
    end

    context 'with hint' do
      let(:result) { builder.check_box(:first_name, hint: 'Check this box') }

      it 'outputs a hint' do
        expect(result).to have_element(:span, text: 'Check this box', class: 'usa-checkbox__label-description')
      end
    end
  end

  describe '#radio_button' do
    let(:result) { builder.radio_button(:first_name, 'yes') }

    it 'outputs a radio button' do
      expect(result).to have_element(:div, class: 'usa-radio')
      expect(result).to have_element(:input, type: 'radio', class: 'usa-radio__input', name: 'object[first_name]', value: 'yes')
    end

    context 'with hint' do
      let(:result) { builder.radio_button(:first_name, 'yes', hint: 'Select yes') }

      it 'outputs a hint' do
        expect(result).to have_element(:span, text: 'Select yes', class: 'usa-radio__label-description')
      end
    end
  end

  describe '#tax_id_field' do
    let(:result) { builder.tax_id_field(:first_name) }

    it 'outputs a text input' do
      expect(result).to have_element(:input, type: 'text', class: 'usa-input', name: 'object[first_name]')
      expect(result).not_to have_css('.usa-form-group--error')
      expect(result).not_to have_css('.usa-error-message')
    end

    it 'outputs a label' do
      expect(result).to have_element(:label, class: 'usa-label', for: 'object_first_name')
    end

    it 'includes an example in the hint' do
      expect(result).to have_element(:p, text: "For example, 123456789")
    end
  end

  describe '#yes_no' do
    let(:result) { builder.yes_no(:first_name, legend: 'Custom legend') }

    it 'outputs radio buttons for yes and no' do
      expect(result).to have_element(:input, type: 'radio', class: 'usa-radio__input', value: 'true', name: 'object[first_name]')
      expect(result).to have_element(:input, type: 'radio', class: 'usa-radio__input', value: 'false', name: 'object[first_name]')

      expect(result).to have_element(:label, text: 'Yes', class: 'usa-radio__label')
      expect(result).to have_element(:label, text: 'No', class: 'usa-radio__label')

      expect(result).to have_element(:legend, text: 'Custom legend', class: 'usa-legend')
    end

    context 'with custom labels' do
      let(:result) { builder.yes_no(:first_name,
        yes_options: { label: "Yes, I've taken leave before" },
        no_options: { label: "No, I haven't taken leave before" }
      ) }

      it 'outputs radio buttons with custom labels' do
        expect(result).to have_element(:label, text: "Yes, I've taken leave before")
        expect(result).to have_element(:label, text: "No, I haven't taken leave before")
      end
    end
  end

  describe '#memorable_date' do
    let(:result) { builder.memorable_date(:date_of_birth) }
    let(:object) { TestRecord.new }

    it 'includes a month select with all months' do
      expect(result).to have_element(:select, name: 'object[date_of_birth][month]')
      Date::MONTHNAMES.compact.each do |month_name|
        expect(result).to have_element(:option, text: month_name)
      end
    end

    it 'includes day and year number inputs' do
      expect(result).to have_element(:input, name: 'object[date_of_birth][day]')
      expect(result).to have_element(:input, name: 'object[date_of_birth][year]')
    end

    context 'with an existing date value' do
      let(:object) { TestRecord.new(date_of_birth: Date.new(2024, 3, 15)) }

      it 'pre-fills the month, day, and year fields' do
        expect(result).to have_element(:select) do |select|
          expect(select).to have_element(:option, text: 'March', selected: true)
        end
        expect(result).to have_element(:input, name: 'object[date_of_birth][day]', value: '15')
        expect(result).to have_element(:input, name: 'object[date_of_birth][year]', value: '2024')
      end
    end

    context 'with raw values' do
      before do
        allow(object).to receive(:date_of_birth_before_type_cast).and_return({ month: '3', day: '44', year: '2024' })
      end

      it 'pre-fills the month, day, and year fields from raw values' do
        expect(result).to have_element(:select) do |select|
          expect(select).to have_element(:option, value: '3', selected: true)
        end
        expect(result).to have_element(:input, name: 'object[date_of_birth][day]', value: '44')
        expect(result).to have_element(:input, name: 'object[date_of_birth][year]', value: '2024')
      end
    end

    context 'with custom legend and hint' do
      let(:result) { builder.memorable_date(:date_of_birth, legend: 'Custom Date', hint: 'Custom hint text') }

      it 'displays the custom legend and hint' do
        expect(result).to have_element(:legend, text: 'Custom Date', class: 'usa-legend')
        expect(result).to have_element(:span, text: 'Custom hint text', class: 'usa-hint')
      end
    end

    context 'with errors' do
      before do
        object.errors.add(:date_of_birth, :invalid_date)
      end

      it 'displays the error message' do
        expect(result).to have_element(:span, text: 'Date of birth is an invalid date')
      end
    end
  end

  describe '#name' do
    let(:result) { builder.name(:name) }
    let(:object) { TestRecord.new }

    it 'includes first, middle, and last name fields' do
      expect(result).to have_element(:input, name: 'object[name][first]')
      expect(result).to have_element(:input, name: 'object[name][middle]')
      expect(result).to have_element(:input, name: 'object[name][last]')
    end

    it 'applies the usa-input--xl class to all input fields' do
      expect(result).to have_element(:input, name: 'object[name][first]', class: /usa-input--xl/)
      expect(result).to have_element(:input, name: 'object[name][middle]', class: /usa-input--xl/)
      expect(result).to have_element(:input, name: 'object[name][last]', class: /usa-input--xl/)
    end

    it 'marks the middle name as optional' do
      expect(result).to have_element(:label, text: /Middle name.*optional/i)
    end

    it 'includes hints for first and last name' do
      expect(result).to have_element(:div, text: /For example, Jose, Darren, or Mai/, class: 'usa-hint')
      expect(result).to have_element(:div, text: /For example, Martinez Gonzalez, Gu, or Smith/, class: 'usa-hint')
    end

    it 'uses I18n for labels' do
      expect(result).to have_element(:label, text: /First or given name/)
      expect(result).to have_element(:label, text: /Middle name/)
      expect(result).to have_element(:label, text: /Last or family name/)
    end

    it 'adds appropriate autocomplete attributes to name fields' do
      expect(result).to have_element(:input, name: 'object[name][first]', autocomplete: 'given-name')
      expect(result).to have_element(:input, name: 'object[name][middle]', autocomplete: 'additional-name')
      expect(result).to have_element(:input, name: 'object[name][last]', autocomplete: 'family-name')
    end

    context 'with an existing name value' do
      let(:object) { TestRecord.new(name: Flex::Name.new("John", "A", "Doe")) }

      it 'pre-fills the name fields' do
        expect(result).to have_element(:input, name: 'object[name][first]', value: 'John')
        expect(result).to have_element(:input, name: 'object[name][middle]', value: 'A')
        expect(result).to have_element(:input, name: 'object[name][last]', value: 'Doe')
      end
    end

    context 'with custom legend and hints' do
      let(:result) { builder.name(:name,
        legend: 'Custom Name Legend',
        first_hint: 'Custom first name hint',
        last_hint: 'Custom last name hint'
      ) }

      it 'displays the custom legend and hints' do
        expect(result).to have_element(:legend, text: 'Custom Name Legend', class: 'usa-legend')
        expect(result).to have_element(:div, text: 'Custom first name hint', class: 'usa-hint')
        expect(result).to have_element(:div, text: 'Custom last name hint', class: 'usa-hint')
      end
    end
  end
end
