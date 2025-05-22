require 'rails_helper'

RSpec.describe "test_records/edit.html.erb", type: :view do
  let(:test_record) { TestRecord.new }

  before do
    assign(:test_record, test_record)
    render
  end

  describe '#name' do
    it 'includes first, middle, and last name fields' do
      expect(rendered).to have_element(:input, name: 'test_record[name][first]')
      expect(rendered).to have_element(:input, name: 'test_record[name][middle]')
      expect(rendered).to have_element(:input, name: 'test_record[name][last]')
    end

    it 'applies the usa-input--xl class to all input fields' do
      expect(rendered).to have_element(:input, name: 'test_record[name][first]', class: /usa-input--xl/)
      expect(rendered).to have_element(:input, name: 'test_record[name][middle]', class: /usa-input--xl/)
      expect(rendered).to have_element(:input, name: 'test_record[name][last]', class: /usa-input--xl/)
    end

    it 'marks the middle name as optional' do
      expect(rendered).to have_element(:label, text: /Middle name.*optional/i)
    end

    it 'includes hints for first and last name' do
      expect(rendered).to have_element(:div, text: /For example, Jose, Darren, or Mai/, class: 'usa-hint')
      expect(rendered).to have_element(:div, text: /For example, Martinez Gonzalez, Gu, or Smith/, class: 'usa-hint')
    end

    it 'uses I18n for labels' do
      expect(rendered).to have_element(:label, text: /First or given name/)
      expect(rendered).to have_element(:label, text: /Middle name/)
      expect(rendered).to have_element(:label, text: /Last or family name/)
    end

    context 'with an existing name value' do
      let(:test_record) { TestRecord.new(name: Flex::Name.new("John", "A", "Doe")) }

      before do
        assign(:test_record, test_record)
        render
      end

      it 'pre-fills the name fields' do
        puts rendered
        expect(rendered).to have_element(:input, name: 'test_record[name][first]', value: 'John')
        expect(rendered).to have_element(:input, name: 'test_record[name][middle]', value: 'A')
        expect(rendered).to have_element(:input, name: 'test_record[name][last]', value: 'Doe')
      end
    end

    # context 'with custom legend and hints' do
    #   let(:rendered) { builder.name(:name, 
    #     legend: 'Custom Name Legend', 
    #     first_hint: 'Custom first name hint', 
    #     last_hint: 'Custom last name hint'
    #   ) }

    #   it 'displays the custom legend and hints' do
    #     expect(rendered).to have_element(:legend, text: 'Custom Name Legend', class: 'usa-legend')
    #     expect(rendered).to have_element(:div, text: 'Custom first name hint', class: 'usa-hint')
    #     expect(rendered).to have_element(:div, text: 'Custom last name hint', class: 'usa-hint')
    #   end
    # end
  end
end
