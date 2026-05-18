# frozen_string_literal: true

require "rails_helper"

RSpec.describe Strata::Tasks::ShowComponent, type: :component do
  let(:task) { create(:passport_task, :with_due_on) }
  let(:assigned_user_display_text) { "Jane Doe" }

  before do
    vc_test_controller.request.path_parameters[:controller] = "tasks"
    vc_test_controller.request.path_parameters[:action] = "show"
  end

  describe "default rendering" do
    before do
      render_inline(described_class.new(
        task: task,
        assigned_user_display_text: assigned_user_display_text
      )) do |c|
        # Avoid the dynamic details/<type> partial lookup, which depends on the
        # controller's prepended view path in production.
        c.with_task_details_content { "stub details content" }
      end
    end

    it "renders the task type heading" do
      expect(page).to have_css("h1.section-heading-h1", text: I18n.t("tasks.types.#{task.type.underscore}"))
    end

    it "renders the default breadcrumb trail" do
      expect(page).to have_css("nav.usa-breadcrumb")
      expect(page).to have_link(I18n.t("strata.tasks.breadcrumbs.home"), href: "/")
      expect(page).to have_text(I18n.t("strata.tasks.breadcrumbs.tasks"))
    end

    it "renders the default task info row" do
      expect(page).to have_text(I18n.t("strata.tasks.show.details.status"))
      expect(page).to have_text(I18n.t("strata.tasks.show.details.due_on"))
      expect(page).to have_text(I18n.t("strata.tasks.show.details.assigned_to"))
      expect(page).to have_text(assigned_user_display_text)
    end

    it "renders the task details slot content" do
      expect(page).to have_text("stub details content")
    end

    it "omits the flash alert when no task-message is set" do
      expect(page).not_to have_css(".usa-alert")
    end
  end

  describe "task_info as an array of hashes" do
    before do
      render_inline(described_class.new(
        task: task,
        assigned_user_display_text: assigned_user_display_text,
        task_info: [ { label: "Custom Label", value: "Custom Value" } ]
      )) { |c| c.with_task_details_content { "" } }
    end

    it "renders the custom label and value" do
      expect(page).to have_text("Custom Label")
      expect(page).to have_text("Custom Value")
    end

    it "does not render the default status label" do
      expect(page).not_to have_text(I18n.t("strata.tasks.show.details.status"))
    end
  end

  describe "custom breadcrumbs" do
    let(:custom_breadcrumbs) do
      [
        { text: "Dashboard", link: "/custom" },
        { text: "Current Page" }
      ]
    end

    before do
      render_inline(described_class.new(
        task: task,
        assigned_user_display_text: assigned_user_display_text,
        breadcrumbs: custom_breadcrumbs
      )) { |c| c.with_task_details_content { "" } }
    end

    it "renders the provided breadcrumbs instead of the defaults" do
      expect(page).to have_link("Dashboard", href: "/custom")
      expect(page).to have_text("Current Page")
      expect(page).not_to have_link(I18n.t("strata.tasks.breadcrumbs.home"), href: "/")
    end
  end

  describe "task_details_partial constructor override" do
    before do
      render_inline(described_class.new(
        task: task,
        assigned_user_display_text: assigned_user_display_text,
        task_details_partial: "strata/tasks/task_info",
        task_info: [ { label: "Top Row", value: "row value" } ],
        details_locals: { task_info: [ { label: "Routed", value: "via partial" } ] }
      ))
    end

    it "renders the named partial in the details section with forwarded locals" do
      expect(page).to have_text("Top Row")
      expect(page).to have_text("Routed")
      expect(page).to have_text("via partial")
    end
  end

  describe "slot overrides win over constructor args" do
    before do
      render_inline(described_class.new(
        task: task,
        assigned_user_display_text: assigned_user_display_text,
        breadcrumbs: [ { text: "Ignored Trail" } ],
        task_info: [ { label: "Ignored", value: "Ignored" } ],
        task_details_partial: "strata/tasks/task_info"
      )) do |c|
        c.with_breadcrumbs_content   { "<nav class=\"slot-breadcrumbs\">SLOT</nav>".html_safe }
        c.with_task_info_content     { "<div class=\"slot-task-info\">SLOT</div>".html_safe }
        c.with_task_details_content  { "<div class=\"slot-details\">SLOT</div>".html_safe }
      end
    end

    it "uses the slot content for each region" do
      expect(page).to have_css("nav.slot-breadcrumbs", text: "SLOT")
      expect(page).to have_css("div.slot-task-info", text: "SLOT")
      expect(page).to have_css("div.slot-details", text: "SLOT")
    end

    it "does not render the constructor-arg values for those regions" do
      expect(page).not_to have_text("Ignored Trail")
      expect(page).not_to have_text("Ignored")
    end
  end

  describe "with a task-message flash" do
    before do
      vc_test_controller.flash["task-message"] = "Task marked as completed"
      render_inline(described_class.new(
        task: task,
        assigned_user_display_text: assigned_user_display_text
      )) { |c| c.with_task_details_content { "" } }
    end

    it "renders the alert with the flash text" do
      expect(page).to have_css(".usa-alert .usa-alert__text", text: "Task marked as completed")
    end
  end
end
