# frozen_string_literal: true

require "rails_helper"

# This template is a thin wrapper preserved for backwards-compatibility with
# call sites that still do `render template: "strata/tasks/show", locals: {...}`.
# Its only job is to forward locals to Strata::Tasks::ShowComponent. The
# component itself is covered by spec/components/strata/tasks/show_component_spec.rb,
# so here we only verify that each local lands on the right component argument.
RSpec.describe "strata/tasks/show.html.erb", type: :view do
  let(:task) { create(:passport_task, :with_due_on) }
  let(:component_instance) { instance_double(Strata::Tasks::ShowComponent) }

  before do
    allow(Strata::Tasks::ShowComponent).to receive(:new).and_return(component_instance)
    allow(component_instance).to receive(:render_in).and_return("")
  end

  def render_show(extra_locals = {})
    render template: "strata/tasks/show", locals: { task: task }.merge(extra_locals)
  end

  describe "with only the required task local" do
    before { render_show }

    it "instantiates ShowComponent with the task" do
      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        hash_including(task: task)
      )
    end

    it "passes nil for each optional local that was not provided" do
      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        hash_including(
          assigned_user_display_text: nil,
          task_info: nil,
          breadcrumbs: nil,
          task_details_partial: nil
        )
      )
    end

    it "passes details_locals containing the task" do
      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        hash_including(details_locals: hash_including(task: task))
      )
    end

    it "renders the component" do
      expect(component_instance).to have_received(:render_in)
    end
  end

  describe "forwarding optional locals" do
    it "forwards assigned_user_display_text" do
      render_show(assigned_user_display_text: "Jane Doe")

      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        hash_including(assigned_user_display_text: "Jane Doe")
      )
    end

    it "forwards task_info" do
      task_info = [ { label: "Custom Label", value: "Custom Value" } ]
      render_show(task_info: task_info)

      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        hash_including(task_info: task_info)
      )
    end

    it "forwards breadcrumbs" do
      breadcrumbs = [ { text: "Home", link: "/" }, { text: "Current" } ]
      render_show(breadcrumbs: breadcrumbs)

      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        hash_including(breadcrumbs: breadcrumbs)
      )
    end

    it "forwards task_details_partial" do
      render_show(task_details_partial: "details/custom_partial")

      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        hash_including(task_details_partial: "details/custom_partial")
      )
    end
  end

  describe "details_locals" do
    it "forwards every local verbatim so they reach the details partial" do
      extra_locals = {
        assigned_user_display_text: "Jane Doe",
        application_form: "an application form",
        kase: "a case",
        arbitrary_key: "arbitrary value"
      }

      render_show(extra_locals)

      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        hash_including(
          details_locals: hash_including(
            task: task,
            assigned_user_display_text: "Jane Doe",
            application_form: "an application form",
            kase: "a case",
            arbitrary_key: "arbitrary value"
          )
        )
      )
    end

    it "passes a plain Hash (not a LocalAssigns object) so the component can merge into it" do
      render_show(application_form: "form")

      call_args = nil
      expect(Strata::Tasks::ShowComponent).to have_received(:new) do |**kwargs|
        call_args = kwargs
      end

      expect(call_args[:details_locals]).to be_a(Hash)
    end
  end

  describe "full pass-through" do
    it "forwards every documented local in a single render call" do
      breadcrumbs = [ { text: "Home", link: "/" } ]
      task_info = [ { label: "Status", value: "Pending" } ]

      render_show(
        assigned_user_display_text: "Jane Doe",
        task_info: task_info,
        breadcrumbs: breadcrumbs,
        task_details_partial: "details/custom"
      )

      expect(Strata::Tasks::ShowComponent).to have_received(:new).with(
        task: task,
        assigned_user_display_text: "Jane Doe",
        task_info: task_info,
        breadcrumbs: breadcrumbs,
        task_details_partial: "details/custom",
        details_locals: hash_including(
          task: task,
          assigned_user_display_text: "Jane Doe",
          task_info: task_info,
          breadcrumbs: breadcrumbs,
          task_details_partial: "details/custom"
        )
      )
    end
  end

  describe "content_for(:breadcrumbs)" do
    # The other examples stub ShowComponent.new so they can assert on its
    # constructor args. Here we want the real component (and the nested
    # strata/shared/breadcrumbs partial it renders) so we can verify that
    # content_for(:breadcrumbs) set by the caller is actually yielded in the
    # final output. We use PassportPhotoTask so the component's default
    # details/<task_type> lookup resolves to the existing dummy app partial.
    let(:task) { create(:passport_task, :with_due_on, type: "PassportPhotoTask") }

    before do
      allow(Strata::Tasks::ShowComponent).to receive(:new).and_call_original
      # In production, Strata::TasksController prepends app/views/tasks so the
      # details/<task_type> partial resolves. Mirror that here.
      controller.prepend_view_path Rails.root.join("app/views/tasks")
      # The details partial uses `form_with action: :update`, which resolves
      # against the current request — point it at the dummy app's tasks routes.
      controller.request.path_parameters[:controller] = "tasks"
      controller.request.path_parameters[:action] = "show"
      controller.request.path_parameters[:id] = task.id
    end

    it "renders content_for(:breadcrumbs) provided by the caller" do
      view.content_for(:breadcrumbs) do
        '<nav class="custom-breadcrumbs">Custom Trail</nav>'.html_safe
      end

      render_show(assigned_user_display_text: "Jane Doe", breadcrumbs: [])

      expect(rendered).to have_css("nav.custom-breadcrumbs", text: "Custom Trail")
      expect(rendered).not_to have_css("nav.usa-breadcrumb")
    end
  end
end
