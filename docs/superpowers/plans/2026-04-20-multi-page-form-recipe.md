# Multi-Page Form Recipe Sub-Rule Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `recipe.md.erb` sub-rule to the `strata:rules multi_page_form` generator that gives agents a step-by-step, end-to-end build recipe for a multi-page intake flow — mirroring the application_form recipe pattern and closing usage gaps that the existing four sub-rules leave open (they describe what the primitives *are*, not *how to wire them together*).

**Architecture:** The existing `Strata::Generators::RulesGenerator` already auto-discovers every `.md.erb` in `lib/generators/strata/rules/templates/multi_page_form/` and renders it to `.agents/rules/strata-sdk/strata-multi-page-form/<name>.md`. Adding `recipe.md.erb` to that directory is sufficient to ship it — no generator code changes required. The root rule file (`multi_page_form.md.erb`) gets a "Build Recipe" section that points at the new sub-rule, matching `application_form.md.erb`.

**Tech Stack:** Ruby on Rails engine, Thor/Rails generators, ERB templates, RSpec.

---

## File Structure

**Create:**
- `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb` — new sub-rule template. Mirrors structure of `application_form/recipe.md.erb`: YAML frontmatter with path scopes, overview table, numbered steps with commands + code + tests, recap with sub-rule pointers.

**Modify:**
- `lib/generators/strata/rules/templates/multi_page_form.md.erb` — add "Build Recipe" section pointing at `strata-multi-page-form/recipe.md`; add recipe row to the sub-rules table.
- `spec/lib/generators/strata/generators/rules_generator_spec.rb` — extend the `describe "generating multi_page_form"` block with recipe existence + content assertions, matching the shape of the existing application_form recipe specs.
- `docs/multi-page-form-flows.md` — add a short "Build Recipe" pointer paragraph near the top so human readers know the agent rule exists and where to find the end-to-end walkthrough.

**No changes needed to:**
- `lib/generators/strata/rules/rules_generator.rb` — sub-template discovery is already glob-based.
- `SOURCE_REFERENCES` constant — recipe is instructional, not source-embedding (same as `application_form/recipe.md.erb`).

---

## Gap Analysis (what this recipe must cover)

Grepped the existing four multi_page_form sub-rules and `docs/multi-page-form-flows.md`. They each cover *what a primitive is* but the following usage gaps are not walked end-to-end anywhere:

1. **Flow class file layout** — where to put `app/flows/<name>_flow.rb`, that there is no `strata:flow` generator and consumers must hand-write it.
2. **End-to-end build order** — model → flow → validations → views generator → controller → routes → tests.
3. **Strong params per flow-page update** — `update_<page>` actions use `flow_record.update(permitted_params)` scoped to the fields on the current page; callers need a params method that permits the union of all page fields.
4. **Validation-per-context wiring** — `Flow::PAGE_NAME` constants and `on: Flow::PAGE_NAME` usage are mentioned but there's no single example showing a model with multiple `validates ..., on: Flow::X` lines alongside a request spec that exercises them.
5. **Start/end page wiring** — `start_page :introduction` and `end_page :confirmation` are listed in the DSL reference but nobody shows the matching controller actions, route entries, or view files the consumer must create by hand.
6. **Submit wiring** — `ApplicationForm#submit_application` on the end page is never connected to the flow in any existing rule; consumers hitting the end page must call it themselves.
7. **Conditional pages (`if:` proc)** — one-liner mentioned in flow-dsl.md but no worked example of a page that's conditional on prior answers.
8. **Task dependencies (`depends_on:`)** — described abstractly in flow-dsl.md but no worked example or matching test.
9. **Rendering the task list** — `TaskListComponent.new(flow: @flow)` is shown in views-and-locales.md but the surrounding layout wiring (where `@flow` is set, when to render the sidebar vs. step component) is not.
10. **Testing strategy** — no request spec or system spec template anywhere in the rules for a multi-page flow; application_form recipe has both.

The recipe resolves 1–6 + 10 directly in worked steps. It references flow-dsl.md/views-and-locales.md sub-rules for 7–9 rather than duplicating their detail.

---

## Task 1: Scaffold recipe.md.erb with frontmatter and overview table

**Files:**
- Create: `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`

- [ ] **Step 1: Write the failing recipe-existence test**

Append to `spec/lib/generators/strata/generators/rules_generator_spec.rb` inside the `describe "generating multi_page_form"` block (just before its closing `end`, right after the `views-and-locales` spec on line 343):

```ruby
it "creates the recipe sub-file" do
  expect(File.exist?("#{sub_dir}/recipe.md")).to be true
end

it "recipe sub-file has path-scoped frontmatter" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to start_with("---\n")
  expect(content).to include("paths:")
  expect(content).to include("**/app/flows/**/*_flow.rb")
  expect(content).to include("**/app/models/**/*_form.rb")
  expect(content).to include("**/app/controllers/**/*_forms_controller.rb")
end

it "recipe sub-file has title and overview table" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("# Strata SDK: Multi-Page Form — Build Recipe")
  expect(content).to include("| Step | Action |")
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: FAIL — three new examples error with `File.exist?("#{sub_dir}/recipe.md")` returning false.

- [ ] **Step 3: Create the recipe template with frontmatter, title, overview**

Create `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`:

```erb
---
paths:
  - "**/app/flows/**/*_flow.rb"
  - "**/app/models/**/*_form.rb"
  - "**/app/controllers/**/*_forms_controller.rb"
  - "**/app/views/**/*_forms/**/*.html.erb"
  - "**/spec/models/**/*_form_spec.rb"
  - "**/spec/requests/**/*_forms_spec.rb"
  - "**/spec/system/**/*_form_spec.rb"
---

# Strata SDK: Multi-Page Form — Build Recipe

Step-by-step recipe for building a multi-page intake flow end-to-end. Do steps in order. Each step: generate or write code, then test, then commit.

Unlike `strata:application_form`, there is no generator for the `ApplicationFormFlow` class itself — it is hand-written. Every other piece has a generator or an SDK mixin.

## Overview

| Step | Action | Deliverable |
|------|--------|-------------|
| 1 | Generate form model + migration | `bin/rails g strata:application_form NAME attr:type ...` |
| 2 | Hand-write the flow class | `app/flows/<name>_flow.rb` |
| 3 | Wire per-page validations | `validate_flow` + `on: Flow::PAGE` |
| 4 | Generate views + layout + locales | `bin/rails g strata:application_form_views FLOW FORM` |
| 5 | Write controller | `include Strata::Flows::ApplicationFormController` |
| 6 | Wire routes | `resources :..._forms { member { Flow.pages.each } }` |
| 7 | Build start/end pages + submit | `start_page`, `end_page`, confirmation view |
| 8 | Test: model + request + system | Three spec files per the templates below |
```

- [ ] **Step 4: Run test to verify the three new examples pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: PASS on the three new specs; existing specs in that block remain green.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Scaffold multi_page_form recipe sub-rule template"
```

---

## Task 2: Add Step 1 (generate model) and Step 2 (flow class) to recipe

**Files:**
- Modify: `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`
- Modify: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write failing content tests**

Append to the same `describe "generating multi_page_form"` block, after the existing recipe specs:

```ruby
it "recipe Step 1 generates the application form model" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Step 1: Generate the Application Form Model")
  expect(content).to include("bin/rails generate strata:application_form")
end

it "recipe Step 2 defines the flow class by hand" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Step 2: Hand-Write the Flow Class")
  expect(content).to include("include Strata::Flows::ApplicationFormFlow")
  expect(content).to include("task :")
  expect(content).to include("question_page :")
end
```

- [ ] **Step 2: Run test to verify failure**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: FAIL — two new examples miss the new headers.

- [ ] **Step 3: Append Step 1 and Step 2 sections to recipe.md.erb**

Append to `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`:

```erb

## Step 1: Generate the Application Form Model

Use `strata:application_form` for the backing record — same generator used for single-page forms. Attribute list should be the union of every field referenced by the flow's `question_page` declarations.

```bash
bin/rails generate strata:application_form Leave \
  applicant_name:name date_of_birth:memorable_date \
  leave_type:string leave_start_date:memorable_date leave_end_date:memorable_date
```

```bash
bin/rails db:migrate
```

Column expansion rules (e.g. `name` → `name_first`, `name_middle`, `name_last`, `name_suffix`): see `strata-application-form/attributes.md`.

## Step 2: Hand-Write the Flow Class

No generator exists for the flow class — create `app/flows/<name>_flow.rb` by hand.

```ruby
# app/flows/leave_application_flow.rb
class LeaveApplicationFlow
  include Strata::Flows::ApplicationFormFlow

  task :personal_information do
    question_page :applicant_name, fields: [
      :applicant_name_first, :applicant_name_middle,
      :applicant_name_last, :applicant_name_suffix
    ]
    question_page :date_of_birth
  end

  task :leave_details, depends_on: [:personal_information] do
    question_page :leave_type
    question_page :leave_dates, fields: [:leave_start_date, :leave_end_date]
    question_page :supporting_documents, if: ->(r) { r.leave_type == "medical" }
  end

  start_page :introduction
  end_page   :confirmation
end
```

Rules this example demonstrates:

- `fields:` defaults to `[page_name]` when omitted (see `date_of_birth`). Supply an explicit array when the page covers multiple columns or a differently-named column.
- `depends_on: [:task_name]` locks `leave_details` until `personal_information` is complete.
- `if:` proc skips `supporting_documents` when the record does not meet the condition.
- `start_page` and `end_page` point at route helper stems — you will define the matching controller actions + views in Step 7.

Full DSL source and dependency semantics: see `strata-multi-page-form/flow-dsl.md`.
```

- [ ] **Step 4: Run test to verify pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add recipe Steps 1-2: generate model and hand-write flow class"
```

---

## Task 3: Add Step 3 (validations) and Step 4 (views generator) to recipe

**Files:**
- Modify: `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`
- Modify: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write failing content tests**

Append to the `describe "generating multi_page_form"` block:

```ruby
it "recipe Step 3 wires per-page validations via Flow constants" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Step 3: Wire Per-Page Validations")
  expect(content).to include("include Strata::Flows::ApplicationFormValidations")
  expect(content).to include("validate_flow")
  expect(content).to include("on: Flow::")
end

it "recipe Step 4 runs the views generator" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Step 4: Generate Views, Layout, and Locales")
  expect(content).to include("bin/rails generate strata:application_form_views")
end
```

- [ ] **Step 2: Run test to verify failure**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: FAIL on the two new examples.

- [ ] **Step 3: Append Step 3 and Step 4 sections**

Append to `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`:

```erb

## Step 3: Wire Per-Page Validations

`validate_flow` introspects the flow and generates a `Flow::PAGE_NAME` constant per page (e.g. `Flow::APPLICANT_NAME`, `Flow::DATE_OF_BIRTH`). Scope presence/format rules to those constants so only the current page's fields validate on each step save.

```ruby
# app/models/leave_application_form.rb
class LeaveApplicationForm < Strata::ApplicationForm
  include Strata::Flows::ApplicationFormValidations
  validate_flow LeaveApplicationFlow

  validates :applicant_name_first, presence: true, on: Flow::APPLICANT_NAME
  validates :applicant_name_last,  presence: true, on: Flow::APPLICANT_NAME
  validates :date_of_birth,        presence: true, on: Flow::DATE_OF_BIRTH
  validates :leave_type,           presence: true, on: Flow::LEAVE_TYPE
  validates :leave_start_date,     presence: true, on: Flow::LEAVE_DATES
  validates :leave_end_date,       presence: true, on: Flow::LEAVE_DATES
end
```

By default `validate_flow` also runs every per-page context when `submit_application` is called, catching any record that skipped a page. Disable with `validate_flow LeaveApplicationFlow, validate_on_submit: false` if needed.

Full validation source: see `strata-multi-page-form/pages-tasks-validations.md`.

## Step 4: Generate Views, Layout, and Locales

`strata:application_form_views` creates one `edit_<page>.html.erb` per question page, a shared layout, and a locale file with placeholder labels and hints for every field.

```bash
bin/rails generate strata:application_form_views LeaveApplicationFlow LeaveApplicationForm
```

Generated output:

```
app/views/leave_application_forms/edit_applicant_name.html.erb
app/views/leave_application_forms/edit_date_of_birth.html.erb
app/views/leave_application_forms/edit_leave_type.html.erb
app/views/leave_application_forms/edit_leave_dates.html.erb
app/views/leave_application_forms/edit_supporting_documents.html.erb
app/views/layouts/leave_application_form.html.erb
config/locales/leave_application_forms/en.yml
```

Customize labels/hints in the generated locale file. The generated layout already renders `Strata::Flows::TaskListComponent` in the sidebar — no extra wiring required. Template helper reference: `strata-multi-page-form/views-and-locales.md`.
```

- [ ] **Step 4: Run test to verify pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add recipe Steps 3-4: per-page validations and views generator"
```

---

## Task 4: Add Step 5 (controller) and Step 6 (routes) to recipe

**Files:**
- Modify: `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`
- Modify: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write failing content tests**

Append:

```ruby
it "recipe Step 5 defines the controller with ApplicationFormController mixin" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Step 5: Write the Controller")
  expect(content).to include("include Strata::Flows::ApplicationFormController")
  expect(content).to include("flow LeaveApplicationFlow")
  expect(content).to include("def flow_record")
end

it "recipe Step 6 wires routes via Flow.pages iteration" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Step 6: Wire Routes")
  expect(content).to include("resources :leave_application_forms")
  expect(content).to include("LeaveApplicationFlow.pages.each")
  expect(content).to include("page.edit_pathname")
  expect(content).to include("page.update_pathname")
end
```

- [ ] **Step 2: Run test to verify failure**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: FAIL on the two new examples.

- [ ] **Step 3: Append Step 5 and Step 6**

Append to recipe.md.erb:

```erb

## Step 5: Write the Controller

No Rails generator needed — the SDK mixin provides the `edit_<page>` / `update_<page>` actions for every question page. Consumers supply only:

1. The mixin + `flow` declaration.
2. A `flow_record` method that returns the record under edit (typically loaded + authorized in a `before_action`).
3. Any custom actions (e.g., `introduction`, `confirmation`) declared via `start_page` / `end_page`.

The mixin handles strong params automatically — each `update_<page>` action calls `params.require(...).permit(*page.attributes(model_class))`, which expands `strata_attribute` registrations into the right column list. No manual `permit` needed.

```ruby
# app/controllers/leave_application_forms_controller.rb
class LeaveApplicationFormsController < ApplicationController
  include Strata::Flows::ApplicationFormController

  flow LeaveApplicationFlow
  layout "leave_application_form", only: LeaveApplicationFlow.generated_routes

  before_action :load_form, only: LeaveApplicationFlow.generated_routes + [:show, :confirmation, :introduction]

  def introduction
    # renders app/views/leave_application_forms/introduction.html.erb
  end

  def confirmation
    # Submission lives here so the applicant cannot reach confirmation until every
    # prior page has saved cleanly. See Step 7 for the full submit wiring.
    @leave_application_form.submit_application unless @leave_application_form.submitted?
  end

  def flow_record
    @leave_application_form
  end

  private

  def load_form
    @leave_application_form = authorize(LeaveApplicationForm.find(params[:id]), :update?)
  end
end
```

On a failed `update_<page>`, the mixin re-renders with 422. To customize the error path, define `on_flow_update_invalid` — the mixin calls it before rendering. Full controller/mixin source: `strata-multi-page-form/controller-and-routes.md`.

## Step 6: Wire Routes

Declare a standard `resources` block, then iterate `Flow.pages` to emit one GET/PATCH member pair per question page. Also add top-level member routes for the `start_page`/`end_page` actions (`introduction`, `confirmation`):

```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :leave_application_forms, only: [:index, :new, :show, :create] do
    member do
      get  :introduction
      get  :confirmation

      LeaveApplicationFlow.pages.each do |page|
        get   page.edit_pathname
        patch page.update_pathname
      end
    end
  end
end
```

This produces:

```
GET    /leave_application_forms/:id/introduction
GET    /leave_application_forms/:id/applicant_name
PATCH  /leave_application_forms/:id/applicant_name
GET    /leave_application_forms/:id/date_of_birth
PATCH  /leave_application_forms/:id/date_of_birth
...
GET    /leave_application_forms/:id/confirmation
```

Route helpers generated: `introduction_leave_application_form_path(id)`, `edit_applicant_name_leave_application_form_path(id)`, `update_applicant_name_leave_application_form_path(id)`, etc. These match the pathnames `start_page`/`end_page` and `question_page` declared in Step 2.
```

- [ ] **Step 4: Run test to verify pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add recipe Steps 5-6: controller mixin and route wiring"
```

---

## Task 5: Add Step 7 (start/end pages + submit) to recipe

**Files:**
- Modify: `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`
- Modify: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write failing content tests**

Append:

```ruby
it "recipe Step 7 wires introduction, confirmation, and submit_application" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Step 7: Build Introduction and Confirmation Pages")
  expect(content).to include("submit_application")
  expect(content).to include("introduction.html.erb")
  expect(content).to include("confirmation.html.erb")
end
```

- [ ] **Step 2: Run test to verify failure**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: FAIL on the new example.

- [ ] **Step 3: Append Step 7**

Append to recipe.md.erb:

```erb

## Step 7: Build Introduction and Confirmation Pages

`start_page :introduction` and `end_page :confirmation` only register path hints — the views and controller actions are hand-written. Create both files:

```erb
<%# app/views/leave_application_forms/introduction.html.erb %>
<h1><%%= t(".title") %></h1>
<p><%%= t(".summary") %></p>

<%%= render Strata::Flows::TaskListComponent.new(flow: LeaveApplicationFlow.new(@leave_application_form), show_step_label: true) %>

<%%= link_to t(".start"), edit_applicant_name_leave_application_form_path(@leave_application_form), class: "usa-button" %>
```

```erb
<%# app/views/leave_application_forms/confirmation.html.erb %>
<h1><%%= t(".title") %></h1>
<p><%%= t(".confirmation_body", id: @leave_application_form.id) %></p>
<p><%%= t(".status") %>: <strong><%%= @leave_application_form.status %></strong></p>
```

Submit wiring lives in the `confirmation` action (Step 5): landing on the confirmation route calls `submit_application`, which fires the full `:submit` validation context (union of every page) and publishes the `<Name>ApplicationFormSubmitted` event. If validation fails the applicant is redirected back to the first incomplete page — implement that redirect yourself if you need it, e.g.:

```ruby
def confirmation
  return if @leave_application_form.submitted?

  unless @leave_application_form.submit_application
    flash[:errors] = @leave_application_form.errors.full_messages
    first_failing_page = LeaveApplicationFlow.pages.find { |p| !p.completed?(@leave_application_form) }
    redirect_to first_failing_page.edit_path(@leave_application_form)
  end
end
```

Event publishing and post-submission write-locking: `strata-application-form/core-class.md`.
```

- [ ] **Step 4: Run test to verify pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add recipe Step 7: introduction/confirmation pages and submit wiring"
```

---

## Task 6: Add Step 8 (tests) and Recap to recipe

**Files:**
- Modify: `lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb`
- Modify: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write failing content tests**

Append:

```ruby
it "recipe Step 8 has model, request, and system spec templates" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Step 8: Test the Flow")
  expect(content).to include("type: :request")
  expect(content).to include("type: :system")
  expect(content).to include("spec/models/leave_application_form_spec.rb")
  expect(content).to include("spec/requests/leave_application_forms_spec.rb")
  expect(content).to include("spec/system/leave_application_form_spec.rb")
end

it "recipe ends with a Recap section pointing at sibling sub-rules" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content).to include("## Recap")
  expect(content).to include("strata-multi-page-form/flow-dsl.md")
  expect(content).to include("strata-multi-page-form/controller-and-routes.md")
  expect(content).to include("strata-multi-page-form/pages-tasks-validations.md")
  expect(content).to include("strata-multi-page-form/views-and-locales.md")
end

it "recipe sub-file is under 12,000 characters" do
  content = File.read("#{sub_dir}/recipe.md")
  expect(content.length).to be <= 12_000,
    "recipe.md exceeds 12,000 chars (#{content.length})"
end
```

- [ ] **Step 2: Run test to verify failure**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: FAIL on three new examples.

- [ ] **Step 3: Append Step 8 and Recap**

Append to recipe.md.erb:

```erb

## Step 8: Test the Flow

Three spec files cover the flow: model (validations per context), request (one page edit/update round trip + submission), system (Capybara walk of the full flow).

**Model spec** — `spec/models/leave_application_form_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe LeaveApplicationForm do
  let(:form) { described_class.new(user_id: SecureRandom.uuid) }

  it "validates applicant name only on the APPLICANT_NAME context" do
    expect(form).not_to be_valid(LeaveApplicationForm::Flow::APPLICANT_NAME)
    form.applicant_name_first = "Jane"
    form.applicant_name_last  = "Doe"
    expect(form).to be_valid(LeaveApplicationForm::Flow::APPLICANT_NAME)
  end

  it "validates all contexts on submit" do
    form.save!
    expect(form.submit_application).to be false
    expect(form.errors[:applicant_name_first]).to include("can't be blank")
  end
end
```

**Request spec** — `spec/requests/leave_application_forms_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "LeaveApplicationForms", type: :request do
  let(:form) { LeaveApplicationForm.create!(user_id: SecureRandom.uuid) }

  it "renders edit_applicant_name" do
    get edit_applicant_name_leave_application_form_path(form)
    expect(response).to have_http_status(:success)
  end

  it "saves and advances on valid update_applicant_name" do
    patch update_applicant_name_leave_application_form_path(form), params: {
      leave_application_form: { applicant_name_first: "Jane", applicant_name_last: "Doe" }
    }
    expect(form.reload.applicant_name_first).to eq("Jane")
    expect(response).to redirect_to(edit_date_of_birth_leave_application_form_path(form))
  end

  it "re-renders with 422 on invalid update" do
    patch update_applicant_name_leave_application_form_path(form), params: {
      leave_application_form: { applicant_name_first: "", applicant_name_last: "" }
    }
    expect(response).to have_http_status(:unprocessable_entity)
  end
end
```

**System spec** — `spec/system/leave_application_form_spec.rb`:

```ruby
require "rails_helper"

RSpec.describe "LeaveApplicationForm", type: :system do
  let(:form) { LeaveApplicationForm.create!(user_id: SecureRandom.uuid) }

  it "walks applicant through the first task" do
    visit introduction_leave_application_form_path(form)
    click_link "Begin"

    fill_in "leave_application_form[applicant_name_first]", with: "Jane"
    fill_in "leave_application_form[applicant_name_last]",  with: "Doe"
    click_button "Save and continue"

    expect(page).to have_current_path(edit_date_of_birth_leave_application_form_path(form))
  end
end
```

Run:

```bash
bundle exec rspec spec/models/leave_application_form_spec.rb \
                  spec/requests/leave_application_forms_spec.rb \
                  spec/system/leave_application_form_spec.rb
```

## Recap

Each step: code → test → commit. For deep dives, load these sibling sub-rules (they auto-load by path scope):

| Sub-rule | When it applies |
|----------|-----------------|
| `strata-multi-page-form/flow-dsl.md` | Editing `app/flows/*_flow.rb` — DSL, dependencies, conditional pages |
| `strata-multi-page-form/controller-and-routes.md` | Editing controllers — mixin internals, TaskEvaluator, route generation |
| `strata-multi-page-form/pages-tasks-validations.md` | Editing the form model — validation contexts, Task/QuestionPage internals |
| `strata-multi-page-form/views-and-locales.md` | Editing `app/views/*_forms/*` or locale files — generator output, template helpers, TaskListComponent |
| `strata-application-form/core-class.md` | Deep-dive on `submit_application`, events, post-submission write-lock |
| `strata-application-form/attributes.md` | Column-name expansion for `name`, `address`, `memorable_date`, etc. |
```

- [ ] **Step 4: Run test to verify pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: PASS including the 12,000-char cap.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/multi_page_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add recipe Step 8 (tests) and Recap with sibling sub-rule pointers"
```

---

## Task 7: Link recipe from the root multi_page_form rule file

**Files:**
- Modify: `lib/generators/strata/rules/templates/multi_page_form.md.erb`
- Modify: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write failing tests for the new root-file references**

Append to the `describe "generating multi_page_form"` block:

```ruby
it "root file points to recipe as the build entry point" do
  content = File.read(root_file)
  expect(content).to include("Build Recipe")
  expect(content).to include("strata-multi-page-form/recipe.md")
end

it "root file lists recipe in the sub-rules table" do
  content = File.read(root_file)
  expect(content).to match(/strata-multi-page-form\/recipe\.md.*Build recipe/i)
end
```

- [ ] **Step 2: Run test to verify failure**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: FAIL on two new examples.

- [ ] **Step 3: Add the "Build Recipe" section to multi_page_form.md.erb**

In `lib/generators/strata/rules/templates/multi_page_form.md.erb`, locate the "## Detailed Reference (Sub-rules)" heading (line 93) and insert a new section directly above it:

```erb
## Build Recipe

Building a multi-page form end-to-end = 8 steps: generate model, write flow class, wire validations, generate views, write controller, wire routes, build start/end pages, test. Full recipe with commands, code, and tests:

→ **`strata-multi-page-form/recipe.md`** (auto-loads when editing any flow, form, controller, or view file)

```

Also in the same file, add a new row to the sub-rules table (the existing table starting with `| File | Contents |`). Insert as the FIRST data row so it appears at the top of the sub-rules list:

```
| `strata-sdk/strata-multi-page-form/recipe.md` | Build recipe: 8-step flow workflow (model → flow → validations → views → controller → routes → start/end → tests) |
```

- [ ] **Step 4: Run test to verify pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "generating multi_page_form"`
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/multi_page_form.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Link recipe from root multi_page_form rule file"
```

---

## Task 8: Add a human-readable pointer in docs/multi-page-form-flows.md

**Files:**
- Modify: `docs/multi-page-form-flows.md`

- [ ] **Step 1: Add a "Build Recipe (Agent Rule)" note near the top of the doc**

In `docs/multi-page-form-flows.md`, after the "## Key Features" bullet list (ending at line 12, before `## Design Principles` on line 14), insert:

```markdown
## Build Recipe (Agent Rule)

For an end-to-end, step-by-step walkthrough of building a multi-page form (model → flow → validations → views → controller → routes → start/end pages → tests), generate the Strata agent rules and open the recipe sub-rule:

```bash
bin/rails generate strata:rules multi_page_form
```

This writes `.agents/rules/strata-sdk/strata-multi-page-form/recipe.md`, which walks through a complete `LeaveApplicationForm` example including every command, file, and test needed. The recipe is the preferred entry point for building new flows; the sections below cover each primitive in isolation.

```

This is a non-test-driven change (plain doc edit) — no spec. Verify by reading the rendered doc or previewing it.

- [ ] **Step 2: Commit**

```bash
git add docs/multi-page-form-flows.md
git commit -m "Point docs reader at the generated multi-page form recipe"
```

---

## Task 9: Full regression pass + lint

**Files:**
- No file changes — verification only.

- [ ] **Step 1: Run the full generator spec file**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb`
Expected: all specs pass (existing + newly added). Every source-reference file still exists, forced overwrite still works, `--agent` flag paths still work.

- [ ] **Step 2: Run the full test suite**

Run: `make test`
Expected: green. Adding a new template file and edits to spec should not affect any other feature.

- [ ] **Step 3: Run the linter**

Run: `make lint`
Expected: clean. The only Ruby files touched are specs — no new cops should fire. ERB templates are not rubocop-checked but should still be reasonable.

- [ ] **Step 4: Manual smoke test — regenerate the rules into a scratch dir**

Run:

```bash
cd spec/dummy && bundle exec rails generate strata:rules multi_page_form --force
```

Expected: writes (or overwrites) seven files, including the new `recipe.md`:

```
.agents/rules/strata-sdk/strata-multi-page-form.md
.agents/rules/strata-sdk/strata-multi-page-form/recipe.md
.agents/rules/strata-sdk/strata-multi-page-form/flow-dsl.md
.agents/rules/strata-sdk/strata-multi-page-form/controller-and-routes.md
.agents/rules/strata-sdk/strata-multi-page-form/pages-tasks-validations.md
.agents/rules/strata-sdk/strata-multi-page-form/views-and-locales.md
```

Open `strata-multi-page-form/recipe.md` and skim: YAML frontmatter parses, every `<%%= ... %>` has rendered as literal `<%= ... %>` in the ERB-escaped examples, no stray `<%= ... %>` leaked through for helpers we did not invoke.

- [ ] **Step 5: Revert the scratch-dir files (they are ignored but keep the worktree tidy)**

```bash
git checkout -- spec/dummy/.agents 2>/dev/null || rm -rf spec/dummy/.agents
```

- [ ] **Step 6: No commit — regression pass only**

If any step above fails, fix in-place and re-run from Step 1.

---

## Self-Review Notes

- **Spec coverage** — every one of gaps 1–6 + 10 from the "Gap Analysis" section is covered in Steps 2, 3, 5, 6, 7, 8. Gaps 7–9 are acknowledged in the recipe but delegated to `flow-dsl.md` / `views-and-locales.md` to avoid duplication.
- **Placeholder scan** — every step contains concrete code. No "TBD", no "similar to above", no "add appropriate error handling".
- **Type consistency** — flow/model names stay `LeaveApplicationFlow` / `LeaveApplicationForm`, route helpers stay in `edit_<page>_leave_application_form_path` form, validation constants use `Flow::APPLICANT_NAME` / `Flow::DATE_OF_BIRTH` / `Flow::LEAVE_TYPE` / `Flow::LEAVE_DATES` matching the page names declared in Step 2.
- **Character budget** — the 12,000-char cap is asserted in Task 6 Step 1. If the recipe grows past that, the view-and-submit sections (Step 7 and the system spec) are the first to trim — the inline redirect helper in Step 7 is the likeliest excision.
