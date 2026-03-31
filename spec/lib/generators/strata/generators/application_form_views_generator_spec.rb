# frozen_string_literal: true

require 'rails_helper'
require 'generators/strata/application_form_views/application_form_views_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Strata::Generators::ApplicationFormViewsGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:generator) { described_class.new(args, { quiet: true }, destination_root: destination_root) }
  let(:args) { [ "TestApplicationFormFlow", "TestApplicationForm" ] }

  before do
    FileUtils.mkdir_p("#{destination_root}/app/views/test_application_forms")
    generator.invoke_all
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  def view_path(page_name)
    "#{destination_root}/app/views/test_application_forms/edit_#{page_name}.html.erb"
  end

  def view_content(page_name)
    File.read(view_path(page_name))
  end

  describe "basic view generation" do
    it "creates an edit view file for each question page" do
      expect(File.exist?(view_path(:applicant_name))).to be true
      expect(File.exist?(view_path(:date_of_birth))).to be true
      expect(File.exist?(view_path(:employer_name))).to be true
    end

    it "wraps content in strata_form_with using flow_record" do
      content = view_content(:applicant_name)
      expect(content).to include("strata_form_with model: flow_record")
      expect(content).to include("url: @flow_task.update_path")
      expect(content).to include("method: :patch")
    end

    it "includes a heading with i18n key based on page name" do
      content = view_content(:applicant_name)
      expect(content).to include('<h2 class="usa-form-heading">')
      expect(content).to include('t(".applicant_name_title")')
    end

    it "includes the form_buttons partial" do
      content = view_content(:applicant_name)
      expect(content).to include('render partial: "strata/shared/form_buttons"')
      expect(content).to include("back_path: @flow_task.prev_path || @flow.start_path")
    end
  end

  describe "multiple question pages across tasks" do
    it "creates a view file for each question page across tasks" do
      # Pages from different tasks
      expect(File.exist?(view_path(:applicant_name))).to be true
      expect(File.exist?(view_path(:employer_name))).to be true
      expect(File.exist?(view_path(:reviewed))).to be true
    end
  end

  describe "strata attribute detection" do
    it "uses name helper for name attributes" do
      expect(view_content(:applicant_name)).to include("f.name :applicant_name")
    end

    it "uses address_fields helper for address attributes" do
      expect(view_content(:mailing_address)).to include("f.address_fields :mailing_address")
    end

    it "uses memorable_date helper for hash field format" do
      # date_of_birth is defined as { date_of_birth: [:month, :day, :year] } in the flow
      expect(view_content(:date_of_birth)).to include("f.memorable_date :date_of_birth")
    end

    it "uses money_field helper for money attributes" do
      expect(view_content(:salary)).to include("f.money_field :salary")
    end

    it "uses tax_id_field helper for tax_id attributes" do
      expect(view_content(:ssn)).to include("f.tax_id_field :ssn")
    end

    it "uses date_picker helper for us_date attributes" do
      expect(view_content(:hire_date)).to include("f.date_picker :hire_date")
    end
  end

  describe "enum fields" do
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
    it "uses the yes_no form helper" do
      expect(view_content(:reviewed)).to include("f.yes_no :reviewed")
    end
  end

  describe "standard column types" do
    it "uses date_picker for date columns" do
      expect(view_content(:start_date)).to include("f.date_picker :start_date")
    end

    it "uses text_area for text columns" do
      expect(view_content(:notes)).to include("f.text_area :notes")
    end

    it "uses text_field with numeric inputmode for integer columns" do
      content = view_content(:age)
      expect(content).to include("f.text_field :age")
      expect(content).to include('inputmode: "numeric"')
    end

    it "uses text_field for string columns" do
      expect(view_content(:employer_name)).to include("f.text_field :employer_name")
    end
  end

  describe "field filtering" do
    it "skips fields ending in _attributes" do
      content = view_content(:details)
      expect(content).not_to include("income_records_attributes")
      expect(content).to include("f.text_field :employer_name")
    end

    it "skips fields not present on the application form" do
      content = view_content(:info)
      expect(content).not_to include("flow_only_field")
      expect(content).to include("f.text_field :employer_name")
    end
  end

  describe "multiple fields on one page" do
    it "includes all fields in the view" do
      content = view_content(:contact_info)
      expect(content).to include("f.text_field :employer_name")
      expect(content).to include("f.text_area :notes")
    end
  end

  describe "locale file generation" do
    let(:locale_path) { "#{destination_root}/config/locales/test_application_forms/en.yml" }

    def locale_yaml
      YAML.safe_load(File.read(locale_path))
    end

    it "creates a locale file" do
      expect(File.exist?(locale_path)).to be true
    end

    it "nests translations under the form name and edit page" do
      translations = locale_yaml.dig("en", "test_application_forms", "edit_applicant_name")
      expect(translations).to be_a(Hash)
    end

    it "generates a humanized title for the page" do
      title = locale_yaml.dig("en", "test_application_forms", "edit_applicant_name", "applicant_name_title")
      expect(title).to eq("Applicant name")
    end

    it "generates a legend translation for enum fieldsets" do
      legend = locale_yaml.dig("en", "test_application_forms", "edit_leave_type", "leave_type_legend")
      expect(legend).to be_a(String)
      expect(legend).not_to be_empty
    end

    it "generates translations for each enum value" do
      translations = locale_yaml.dig("en", "test_application_forms", "edit_leave_type")
      expect(translations["leave_type_medical"]).to eq("Medical")
      expect(translations["leave_type_family"]).to eq("Family")
      expect(translations["leave_type_military"]).to eq("Military")
    end

    it "includes translations for all pages in a single locale file" do
      yaml = locale_yaml
      expect(yaml.dig("en", "test_application_forms", "edit_applicant_name", "applicant_name_title")).to be_a(String)
      expect(yaml.dig("en", "test_application_forms", "edit_date_of_birth", "date_of_birth_title")).to be_a(String)
      expect(yaml.dig("en", "test_application_forms", "edit_employer_name", "employer_name_title")).to be_a(String)
    end

    context "when an existing locale file is present" do
      # Use a separate generator with a fresh destination to control locale file state
      let(:merge_destination) { Dir.mktmpdir }
      let(:merge_generator) { described_class.new(args, { quiet: true }, destination_root: merge_destination) }
      let(:merge_locale_path) { "#{merge_destination}/config/locales/test_application_forms/en.yml" }

      before do
        FileUtils.mkdir_p("#{merge_destination}/app/views/test_application_forms")

        # Create an existing locale file with pre-existing content
        FileUtils.mkdir_p(File.dirname(merge_locale_path))
        File.write(merge_locale_path, <<~YAML)
          en:
            test_application_forms:
              index:
                title: "Existing Title"
        YAML

        merge_generator.invoke_all
      end

      after do
        FileUtils.rm_rf(merge_destination)
      end

      it "preserves existing translations" do
        yaml = YAML.safe_load(File.read(merge_locale_path))
        expect(yaml.dig("en", "test_application_forms", "index", "title")).to eq("Existing Title")
      end

      it "adds new page translations" do
        yaml = YAML.safe_load(File.read(merge_locale_path))
        expect(yaml.dig("en", "test_application_forms", "edit_applicant_name", "applicant_name_title")).to eq("Applicant name")
      end
    end
  end

  describe "form layout generation" do
    let(:layout_path) { "#{destination_root}/app/views/layouts/test_application_form.html.erb" }

    it "creates a layout file" do
      expect(File.exist?(layout_path)).to be true
    end

    it "renders into the :content content_for block" do
      expect(File.read(layout_path)).to include("content_for :content")
    end

    it "renders the application layout template" do
      expect(File.read(layout_path)).to include('render template: "layouts/application"')
    end

    it "renders the exit_link partial" do
      content = File.read(layout_path)
      expect(content).to include('strata/shared/exit_link')
      expect(content).to include("@flow.start_path")
    end

    it "uses a translation key for the exit text" do
      expect(File.read(layout_path)).to include('t("test_application_forms.actions.exit")')
    end

    it "renders the step indicator partial" do
      expect(File.read(layout_path)).to include('strata/shared/step_indicator')
    end

    it "passes step indicator locals from @flow_task" do
      content = File.read(layout_path)
      expect(content).to include("@flow_task.pages.map(&:name)")
      expect(content).to include("@flow_task.current_page.name")
    end

    it "yields the page content" do
      expect(File.read(layout_path)).to include("<%= yield %>")
    end

    it "adds exit translation to locale file" do
      locale_path = "#{destination_root}/config/locales/test_application_forms/en.yml"
      yaml = YAML.safe_load(File.read(locale_path))
      expect(yaml.dig("en", "test_application_forms", "actions", "exit")).to be_a(String)
    end

    context "when form name does not end in 'form'" do
      let(:args) { [ "TestApplicationFormFlow", "TestApplicationForm" ] }

      it "does not double-append _form for names already ending in form" do
        expect(File.exist?(layout_path)).to be true
        expect(File.exist?("#{destination_root}/app/views/layouts/test_application_form_form.html.erb")).to be false
      end
    end
  end

  describe "error handling" do
    context "when the flow class cannot be found" do
      it "raises an error" do
        bad_generator = described_class.new([ "NonExistentFlow", "TestApplicationForm" ], { quiet: true }, destination_root: destination_root)
        expect { bad_generator.invoke_all }.to raise_error(NameError)
      end
    end

    context "when the form class cannot be found" do
      it "raises an error" do
        bad_generator = described_class.new([ "TestApplicationFormFlow", "NonExistentForm" ], { quiet: true }, destination_root: destination_root)
        expect { bad_generator.invoke_all }.to raise_error(NameError)
      end
    end
  end
end
