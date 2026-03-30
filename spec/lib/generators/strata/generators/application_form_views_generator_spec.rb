# frozen_string_literal: true

require 'rails_helper'
require 'generators/strata/application_form_views/application_form_views_generator'
require 'fileutils'
require 'ostruct'
require 'tmpdir'

RSpec.describe Strata::Generators::ApplicationFormViewsGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new(args, { quiet: true }, destination_root: destination_root) }
  let(:args) { [ flow_class_name, form_class_name ] }
  let(:flow_class_name) { "TestFormFlow" }
  let(:form_class_name) { "TestFormApplicationForm" }

  # Build stub classes with the class methods the generator calls
  let(:flow_class) do
    klass = Class.new
    klass.define_singleton_method(:tasks) { [] }
    klass
  end

  let(:form_class) do
    klass = Class.new
    klass.define_singleton_method(:reflect_on_all_attachments) { [] }
    klass.define_singleton_method(:defined_enums) { {} }
    klass.define_singleton_method(:attribute_types) { {} }
    klass.define_singleton_method(:column_names) { [] }
    klass.define_singleton_method(:columns_hash) { {} }
    klass
  end

  before do
    FileUtils.mkdir_p("#{destination_root}/app/views/test_form_application_forms")

    # Register class names so constantize works
    stub_const(flow_class_name, flow_class)
    stub_const(form_class_name, form_class)
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  def view_path(page_name)
    "#{destination_root}/app/views/test_form_application_forms/edit_#{page_name}.html.erb"
  end

  def view_content(page_name)
    File.read(view_path(page_name))
  end

  describe "basic view generation" do
    let(:question_page) { Strata::Flows::QuestionPage.new(:full_name, fields: [ :full_name ]) }
    let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

    before do
      allow(flow_class).to receive(:tasks).and_return([ task ])
      allow(form_class).to receive_messages(attribute_types: { "full_name" => ActiveModel::Type::String.new }, column_names: [ "full_name" ], columns_hash: { "full_name" => OpenStruct.new(type: :string) })
      generator.invoke_all
    end

    it "creates an edit view file for the question page" do
      expect(File.exist?(view_path(:full_name))).to be true
    end

    it "wraps content in strata_form_with using flow_record" do
      content = view_content(:full_name)
      expect(content).to include("strata_form_with model: flow_record")
      expect(content).to include("url: @flow_task.update_path")
      expect(content).to include("method: :patch")
    end

    it "includes a heading with i18n key based on page name" do
      content = view_content(:full_name)
      expect(content).to include('<h2 class="usa-form-heading">')
      expect(content).to include('t(".full_name_title")')
    end

    it "includes the form_buttons partial" do
      content = view_content(:full_name)
      expect(content).to include('render partial: "strata/shared/form_buttons"')
      expect(content).to include("back_path: @flow_task.prev_path || @flow.start_path")
    end

    it "uses text_field for string attributes" do
      content = view_content(:full_name)
      expect(content).to include("f.text_field :full_name")
    end
  end

  describe "multiple question pages across tasks" do
    let(:page_one) { Strata::Flows::QuestionPage.new(:first_name, fields: [ :first_name ]) }
    let(:page_two) { Strata::Flows::QuestionPage.new(:last_name, fields: [ :last_name ]) }
    let(:page_three) { Strata::Flows::QuestionPage.new(:email, fields: [ :email ]) }
    let(:task_one) { instance_double(Strata::Flows::Task, pages: [ page_one, page_two ]) }
    let(:task_two) { instance_double(Strata::Flows::Task, pages: [ page_three ]) }

    before do
      allow(flow_class).to receive(:tasks).and_return([ task_one, task_two ])
      allow(form_class).to receive_messages(attribute_types: {
        "first_name" => ActiveModel::Type::String.new,
        "last_name" => ActiveModel::Type::String.new,
        "email" => ActiveModel::Type::String.new
      }, column_names: %w[first_name last_name email], columns_hash: {
        "first_name" => OpenStruct.new(type: :string),
        "last_name" => OpenStruct.new(type: :string),
        "email" => OpenStruct.new(type: :string)
      })
      generator.invoke_all
    end

    it "creates a view file for each question page" do
      expect(File.exist?(view_path(:first_name))).to be true
      expect(File.exist?(view_path(:last_name))).to be true
      expect(File.exist?(view_path(:email))).to be true
    end
  end

  describe "strata attribute detection" do
    context "with a memorable_date attribute" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:date_of_birth, fields: [ :date_of_birth ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "date_of_birth" => Strata::Attributes::MemorableDateAttribute::MemorableDate.new
        }, column_names: [ "date_of_birth" ])
        generator.invoke_all
      end

      it "uses memorable_date helper" do
        content = view_content(:date_of_birth)
        expect(content).to include("f.memorable_date :date_of_birth")
      end
    end

    context "with a memorable_date attribute in hash field format" do
      let(:question_page) do
        Strata::Flows::QuestionPage.new(:birth_date, fields: [
          { date_of_birth: [ :month, :day, :year ] }
        ])
      end
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "date_of_birth" => Strata::Attributes::MemorableDateAttribute::MemorableDate.new
        }, column_names: [ "date_of_birth" ])
        generator.invoke_all
      end

      it "uses memorable_date helper for the hash key" do
        content = view_content(:birth_date)
        expect(content).to include("f.memorable_date :date_of_birth")
      end
    end

    context "with a hash field that is a us_date" do
      let(:question_page) do
        Strata::Flows::QuestionPage.new(:start_date, fields: [
          { start_date: [ :month, :day, :year ] }
        ])
      end
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "start_date" => Strata::Attributes::USDateAttribute::USDateType.new
        }, column_names: [ "start_date" ])
        generator.invoke_all
      end

      it "uses date_picker helper" do
        content = view_content(:start_date)
        expect(content).to include("f.date_picker :start_date")
      end
    end

    context "with a hash field for a non-date strata attribute" do
      let(:question_page) do
        Strata::Flows::QuestionPage.new(:applicant_name, fields: [
          { applicant_name: [ :first, :middle, :last, :suffix ] }
        ])
      end
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive(:method_defined?).with(:applicant_name).and_return(true)
        allow(form_class).to receive_messages(attribute_types: {
          "applicant_name_first" => ActiveModel::Type::String.new,
          "applicant_name_middle" => ActiveModel::Type::String.new,
          "applicant_name_last" => ActiveModel::Type::String.new,
          "applicant_name_suffix" => ActiveModel::Type::String.new
        }, column_names: %w[applicant_name_first applicant_name_middle applicant_name_last applicant_name_suffix])
        generator.invoke_all
      end

      it "detects the strata attribute type and uses the appropriate helper" do
        content = view_content(:applicant_name)
        expect(content).to include("f.name :applicant_name")
      end
    end

    context "with a money attribute" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:salary, fields: [ :salary ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "salary" => Strata::Attributes::MoneyAttribute::MoneyType.new
        }, column_names: [ "salary" ])
        generator.invoke_all
      end

      it "uses money_field helper" do
        content = view_content(:salary)
        expect(content).to include("f.money_field :salary")
      end
    end

    context "with a tax_id attribute" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:ssn, fields: [ :ssn ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "ssn" => Strata::Attributes::TaxIdAttribute::TaxIdType.new
        }, column_names: [ "ssn" ])
        generator.invoke_all
      end

      it "uses tax_id_field helper" do
        content = view_content(:ssn)
        expect(content).to include("f.tax_id_field :ssn")
      end
    end

    context "with a us_date attribute" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:hire_date, fields: [ :hire_date ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "hire_date" => Strata::Attributes::USDateAttribute::USDateType.new
        }, column_names: [ "hire_date" ])
        generator.invoke_all
      end

      it "uses date_picker helper" do
        content = view_content(:hire_date)
        expect(content).to include("f.date_picker :hire_date")
      end
    end

    context "with a name attribute (multi-column)" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:applicant_name, fields: [ :applicant_name ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive(:method_defined?).with(:applicant_name).and_return(true)
        allow(form_class).to receive_messages(attribute_types: {
          "applicant_name_first" => ActiveModel::Type::String.new,
          "applicant_name_middle" => ActiveModel::Type::String.new,
          "applicant_name_last" => ActiveModel::Type::String.new,
          "applicant_name_suffix" => ActiveModel::Type::String.new
        }, column_names: %w[applicant_name_first applicant_name_middle applicant_name_last applicant_name_suffix], columns_hash: {
          "applicant_name_first" => OpenStruct.new(type: :string)
        })
        generator.invoke_all
      end

      it "uses name helper" do
        content = view_content(:applicant_name)
        expect(content).to include("f.name :applicant_name")
      end
    end

    context "with an address attribute (multi-column)" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:mailing_address, fields: [ :mailing_address ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive(:method_defined?).with(:mailing_address).and_return(true)
        allow(form_class).to receive_messages(attribute_types: {
          "mailing_address_street_line_1" => ActiveModel::Type::String.new,
          "mailing_address_street_line_2" => ActiveModel::Type::String.new,
          "mailing_address_city" => ActiveModel::Type::String.new,
          "mailing_address_state" => ActiveModel::Type::String.new,
          "mailing_address_zip_code" => ActiveModel::Type::String.new
        }, column_names: %w[mailing_address_street_line_1 mailing_address_street_line_2 mailing_address_city mailing_address_state mailing_address_zip_code], columns_hash: {
          "mailing_address_street_line_1" => OpenStruct.new(type: :string)
        })
        generator.invoke_all
      end

      it "uses address_fields helper" do
        content = view_content(:mailing_address)
        expect(content).to include("f.address_fields :mailing_address")
      end
    end
  end

  describe "enum fields" do
    let(:question_page) { Strata::Flows::QuestionPage.new(:leave_type, fields: [ :leave_type ]) }
    let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

    before do
      allow(flow_class).to receive(:tasks).and_return([ task ])
      allow(form_class).to receive_messages(defined_enums: {
        "leave_type" => { "medical" => 0, "family" => 1, "military" => 2 }
      }, attribute_types: {
        "leave_type" => ActiveModel::Type::Integer.new
      }, column_names: [ "leave_type" ])
      generator.invoke_all
    end

    it "renders a fieldset with radio buttons for each enum value" do
      content = view_content(:leave_type)
      expect(content).to include("f.fieldset")
      expect(content).to include("f.radio_button :leave_type")
      expect(content).to include('"medical"')
      expect(content).to include('"family"')
      expect(content).to include('"military"')
    end
  end

  describe "boolean fields" do
    let(:question_page) { Strata::Flows::QuestionPage.new(:reviewed, fields: [ :reviewed ]) }
    let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

    before do
      allow(flow_class).to receive(:tasks).and_return([ task ])
      allow(form_class).to receive_messages(attribute_types: {
        "reviewed" => ActiveModel::Type::Boolean.new
      }, column_names: [ "reviewed" ], columns_hash: {
        "reviewed" => OpenStruct.new(type: :boolean)
      })
      generator.invoke_all
    end

    it "uses the yes_no form helper" do
      content = view_content(:reviewed)
      expect(content).to include("f.yes_no :reviewed")
    end
  end

  describe "standard column types" do
    context "with a date column" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:start_date, fields: [ :start_date ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "start_date" => ActiveModel::Type::Date.new
        }, column_names: [ "start_date" ], columns_hash: {
          "start_date" => OpenStruct.new(type: :date)
        })
        generator.invoke_all
      end

      it "uses date_picker helper" do
        content = view_content(:start_date)
        expect(content).to include("f.date_picker :start_date")
      end
    end

    context "with a text column" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:notes, fields: [ :notes ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "notes" => ActiveModel::Type::String.new
        }, column_names: [ "notes" ], columns_hash: {
          "notes" => OpenStruct.new(type: :text)
        })
        generator.invoke_all
      end

      it "uses text_area helper" do
        content = view_content(:notes)
        expect(content).to include("f.text_area :notes")
      end
    end

    context "with an integer column" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:age, fields: [ :age ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "age" => ActiveModel::Type::Integer.new
        }, column_names: [ "age" ], columns_hash: {
          "age" => OpenStruct.new(type: :integer)
        })
        generator.invoke_all
      end

      it "uses text_field with numeric inputmode" do
        content = view_content(:age)
        expect(content).to include("f.text_field :age")
        expect(content).to include('inputmode: "numeric"')
      end
    end
  end

  describe "field filtering" do
    context "with fields ending in _attributes (nested attributes)" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:details, fields: [ :details, :income_records_attributes ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "details" => ActiveModel::Type::String.new
        }, column_names: [ "details" ], columns_hash: {
          "details" => OpenStruct.new(type: :string)
        })
        generator.invoke_all
      end

      it "skips fields ending in _attributes" do
        content = view_content(:details)
        expect(content).not_to include("income_records_attributes")
      end

      it "still includes other fields" do
        content = view_content(:details)
        expect(content).to include("f.text_field :details")
      end
    end

    context "with attachment fields" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:documents, fields: [ :resume, :cover_letter ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        resume_attachment = OpenStruct.new(name: :resume)
        cover_letter_attachment = OpenStruct.new(name: :cover_letter)
        allow(form_class).to receive(:reflect_on_all_attachments).and_return([ resume_attachment, cover_letter_attachment ])
        generator.invoke_all
      end

      it "skips attachment fields" do
        content = view_content(:documents)
        expect(content).not_to include(":resume")
        expect(content).not_to include(":cover_letter")
      end
    end

    context "with fields that only exist on the flow, not the application form" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:info, fields: [ :real_field, :flow_only_field ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: {
          "real_field" => ActiveModel::Type::String.new
        }, column_names: [ "real_field" ], columns_hash: {
          "real_field" => OpenStruct.new(type: :string)
        })
        generator.invoke_all
      end

      it "skips fields not present on the application form" do
        content = view_content(:info)
        expect(content).not_to include("flow_only_field")
      end

      it "still includes fields that exist on the form" do
        content = view_content(:info)
        expect(content).to include("f.text_field :real_field")
      end
    end
  end

  describe "multiple fields on one page" do
    let(:question_page) { Strata::Flows::QuestionPage.new(:contact_info, fields: [ :email, :phone_number ]) }
    let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

    before do
      allow(flow_class).to receive(:tasks).and_return([ task ])
      allow(form_class).to receive_messages(attribute_types: {
        "email" => ActiveModel::Type::String.new,
        "phone_number" => ActiveModel::Type::String.new
      }, column_names: %w[email phone_number], columns_hash: {
        "email" => OpenStruct.new(type: :string),
        "phone_number" => OpenStruct.new(type: :string)
      })
      generator.invoke_all
    end

    it "includes all fields in the view" do
      content = view_content(:contact_info)
      expect(content).to include("f.text_field :email")
      expect(content).to include("f.text_field :phone_number")
    end
  end

  describe "locale file generation" do
    let(:locale_path) { "#{destination_root}/config/locales/test_form_application_forms/en.yml" }

    def locale_yaml
      YAML.safe_load(File.read(locale_path))
    end

    context "with a simple text field page" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:full_name, fields: [ :full_name ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: { "full_name" => ActiveModel::Type::String.new }, column_names: [ "full_name" ], columns_hash: { "full_name" => OpenStruct.new(type: :string) })
        generator.invoke_all
      end

      it "creates a locale file" do
        expect(File.exist?(locale_path)).to be true
      end

      it "nests translations under the form name and edit page" do
        translations = locale_yaml.dig("en", "test_form_application_forms", "edit_full_name")
        expect(translations).to be_a(Hash)
      end

      it "generates a humanized title for the page" do
        title = locale_yaml.dig("en", "test_form_application_forms", "edit_full_name", "full_name_title")
        expect(title).to eq("Full name")
      end
    end

    context "with an enum field" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:leave_type, fields: [ :leave_type ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(defined_enums: {
          "leave_type" => { "medical" => 0, "family" => 1, "military" => 2 }
        }, attribute_types: {
          "leave_type" => ActiveModel::Type::Integer.new
        }, column_names: [ "leave_type" ])
        generator.invoke_all
      end

      it "generates a legend translation for the enum fieldset" do
        legend = locale_yaml.dig("en", "test_form_application_forms", "edit_leave_type", "leave_type_legend")
        expect(legend).to be_a(String)
        expect(legend).not_to be_empty
      end

      it "generates translations for each enum value" do
        translations = locale_yaml.dig("en", "test_form_application_forms", "edit_leave_type")
        expect(translations["leave_type_medical"]).to eq("Medical")
        expect(translations["leave_type_family"]).to eq("Family")
        expect(translations["leave_type_military"]).to eq("Military")
      end
    end

    context "with multiple pages across tasks" do
      let(:page_one) { Strata::Flows::QuestionPage.new(:first_name, fields: [ :first_name ]) }
      let(:page_two) { Strata::Flows::QuestionPage.new(:date_of_birth, fields: [ :date_of_birth ]) }
      let(:task_one) { instance_double(Strata::Flows::Task, pages: [ page_one ]) }
      let(:task_two) { instance_double(Strata::Flows::Task, pages: [ page_two ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task_one, task_two ])
        allow(form_class).to receive_messages(attribute_types: {
          "first_name" => ActiveModel::Type::String.new,
          "date_of_birth" => Strata::Attributes::MemorableDateAttribute::MemorableDate.new
        }, column_names: %w[first_name date_of_birth], columns_hash: {
          "first_name" => OpenStruct.new(type: :string)
        })
        generator.invoke_all
      end

      it "includes translations for all pages in a single locale file" do
        yaml = locale_yaml
        expect(yaml.dig("en", "test_form_application_forms", "edit_first_name", "first_name_title")).to be_a(String)
        expect(yaml.dig("en", "test_form_application_forms", "edit_date_of_birth", "date_of_birth_title")).to be_a(String)
      end
    end

    context "when an existing locale file is present" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:full_name, fields: [ :full_name ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: { "full_name" => ActiveModel::Type::String.new }, column_names: [ "full_name" ], columns_hash: { "full_name" => OpenStruct.new(type: :string) })

        # Create an existing locale file with pre-existing content
        FileUtils.mkdir_p(File.dirname(locale_path))
        File.write(locale_path, <<~YAML)
          en:
            test_form_application_forms:
              index:
                title: "Existing Title"
        YAML

        generator.invoke_all
      end

      it "preserves existing translations" do
        existing_title = locale_yaml.dig("en", "test_form_application_forms", "index", "title")
        expect(existing_title).to eq("Existing Title")
      end

      it "adds new page translations" do
        new_title = locale_yaml.dig("en", "test_form_application_forms", "edit_full_name", "full_name_title")
        expect(new_title).to eq("Full name")
      end
    end

    context "with a multi-word page name" do
      let(:question_page) { Strata::Flows::QuestionPage.new(:employer_name, fields: [ :employer_name ]) }
      let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

      before do
        allow(flow_class).to receive(:tasks).and_return([ task ])
        allow(form_class).to receive_messages(attribute_types: { "employer_name" => ActiveModel::Type::String.new }, column_names: [ "employer_name" ], columns_hash: { "employer_name" => OpenStruct.new(type: :string) })
        generator.invoke_all
      end

      it "humanizes the page name" do
        title = locale_yaml.dig("en", "test_form_application_forms", "edit_employer_name", "employer_name_title")
        expect(title).to eq("Employer name")
      end
    end
  end

  describe "form layout generation" do
    let(:layout_path) { "#{destination_root}/app/views/layouts/test_form_application_form.html.erb" }
    let(:question_page) { Strata::Flows::QuestionPage.new(:full_name, fields: [ :full_name ]) }
    let(:task) { instance_double(Strata::Flows::Task, pages: [ question_page ]) }

    before do
      allow(flow_class).to receive(:tasks).and_return([ task ])
      allow(form_class).to receive_messages(attribute_types: { "full_name" => ActiveModel::Type::String.new }, column_names: [ "full_name" ], columns_hash: { "full_name" => OpenStruct.new(type: :string) })
      generator.invoke_all
    end

    it "creates a layout file" do
      expect(File.exist?(layout_path)).to be true
    end

    it "renders into the :content content_for block" do
      content = File.read(layout_path)
      expect(content).to include("content_for :content")
    end

    it "renders the application layout template" do
      content = File.read(layout_path)
      expect(content).to include('render template: "layouts/application"')
    end

    it "renders the exit_link partial" do
      content = File.read(layout_path)
      expect(content).to include('strata/shared/exit_link')
      expect(content).to include("@flow.start_path")
    end

    it "uses a translation key for the exit text" do
      content = File.read(layout_path)
      expect(content).to include('t("test_form_application_forms.actions.exit")')
    end

    it "renders the step indicator partial" do
      content = File.read(layout_path)
      expect(content).to include('strata/shared/step_indicator')
    end

    it "passes step indicator locals from @flow_task" do
      content = File.read(layout_path)
      expect(content).to include("@flow_task.pages.map(&:name)")
      expect(content).to include("@flow_task.current_page.name")
    end

    it "yields the page content" do
      content = File.read(layout_path)
      expect(content).to include("<%= yield %>")
    end

    it "adds exit translation to locale file" do
      locale_path = "#{destination_root}/config/locales/test_form_application_forms/en.yml"
      yaml = YAML.safe_load(File.read(locale_path))
      exit_text = yaml.dig("en", "test_form_application_forms", "actions", "exit")
      expect(exit_text).to be_a(String)
      expect(exit_text).not_to be_empty
    end

    context "when form name does not end in 'form'" do
      let(:form_class_name) { "LeaveApplication" }
      let(:layout_path) { "#{destination_root}/app/views/layouts/leave_application_form.html.erb" }

      before do
        FileUtils.mkdir_p("#{destination_root}/app/views/leave_applications")
      end

      it "appends _form to the layout file name" do
        expect(File.exist?(layout_path)).to be true
      end
    end
  end

  describe "error handling" do
    context "when the flow class cannot be found" do
      it "raises an error" do
        bad_generator = described_class.new([ "NonExistentFlow", form_class_name ], { quiet: true }, destination_root: destination_root)
        expect { bad_generator.invoke_all }.to raise_error(NameError)
      end
    end

    context "when the form class cannot be found" do
      it "raises an error" do
        allow(flow_class).to receive(:tasks).and_return([])
        bad_generator = described_class.new([ flow_class_name, "NonExistentForm" ], { quiet: true }, destination_root: destination_root)
        expect { bad_generator.invoke_all }.to raise_error(NameError)
      end
    end
  end
end
