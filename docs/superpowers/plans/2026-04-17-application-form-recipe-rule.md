# Application Form Recipe Rule Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `recipe.md.erb` sub-rule template to the `strata:rules application_form` generator that documents the end-to-end recipe for building an application form (model → model spec → controller → request spec → views → view spec), and surface it from the root rule file.

**Architecture:** New ERB template at `lib/generators/strata/rules/templates/application_form/recipe.md.erb`. Rendered automatically by the existing `Dir.glob` loop in `RulesGenerator#generate_rules` — no generator code changes needed beyond possible tests. Root template (`application_form.md.erb`) updated to link the recipe as the primary entry point. Recipe content is inline markdown + code blocks (no new SDK source embeds), so `SOURCE_REFERENCES` is unchanged.

**Hard constraints (from user):**
1. **Monorepo path scoping** — every `paths:` entry in every rule's frontmatter MUST start with `**/` so path-scoped loading works from any subdirectory. Enforced by a new generator spec assertion (Task 1). Applies to the new recipe rule AND any existing rule touched.
2. **12 000 character limit per rendered file** — already asserted by the existing `each sub-file is under 12,000 characters` test at `spec/lib/generators/strata/generators/rules_generator_spec.rb:125`. Estimated recipe.md rendered size ≈ 8.9 k chars (Step 3 controller example is the largest chunk at ~2.8 k). Comfortably under. If a future edit pushes it over, split using the contingency plan in Task 6 (`recipe.md` = overview + Steps 1–4, new `recipe-views.md` = Steps 5–6 + Recap).

**Tech Stack:** Ruby on Rails, Thor/Rails generators, ERB templates, RSpec.

---

## File Structure

- Create: `lib/generators/strata/rules/templates/application_form/recipe.md.erb` — new recipe sub-rule (6 numbered steps + overview table + recap)
- Modify: `lib/generators/strata/rules/templates/application_form.md.erb` — add "Build Recipe" section at top, list recipe in sub-rules table
- Modify: `spec/lib/generators/strata/generators/rules_generator_spec.rb` — add tests asserting recipe sub-file exists, has frontmatter, contains each of the 6 step headings, and that every rule's `paths:` entries begin with `**/`

No generator Ruby code changes. No `SOURCE_REFERENCES` changes. No new SDK source reads — recipe is self-contained documentation.

---

## Task 1: Scaffold recipe.md.erb with frontmatter + overview

**Files:**
- Create: `lib/generators/strata/rules/templates/application_form/recipe.md.erb`
- Test: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write the failing test**

Add inside the existing `describe "generating application_form"` block in `spec/lib/generators/strata/generators/rules_generator_spec.rb`:

```ruby
it "creates the recipe sub-file" do
  sub_dir = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form"
  expect(File.exist?("#{sub_dir}/recipe.md")).to be true
end

it "recipe sub-file has path-scoped frontmatter" do
  content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
  expect(content).to start_with("---\n")
  expect(content).to include("paths:")
  expect(content).to include("app/models/**/*application_form*.rb")
end

it "recipe sub-file has title and overview table" do
  content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
  expect(content).to include("# Strata SDK: ApplicationForm — Build Recipe")
  expect(content).to include("| Step | Action |")
end

it "every generated rule file's paths begin with **/ (monorepo-safe)" do
  root_dir = "#{destination_root}/.agents/rules/strata-sdk"
  files = Dir.glob("#{root_dir}/**/*.md")
  expect(files).not_to be_empty

  files.each do |path|
    content = File.read(path)
    frontmatter = content[/\A---\n(.*?)\n---/m, 1]
    expect(frontmatter).not_to be_nil, "#{path} missing frontmatter"

    path_entries = frontmatter.scan(/^\s*-\s*"([^"]+)"/).flatten
    expect(path_entries).not_to be_empty, "#{path} has no path entries"

    path_entries.each do |entry|
      expect(entry).to start_with("**/"),
        "#{path} path entry #{entry.inspect} must start with **/ for monorepo scoping"
    end
  end
end
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "recipe"`
Expected: 3 failures — `recipe.md` does not exist. The monorepo `**/` test is not scoped to "recipe" so won't run in this filter; it will run when the full file runs at Step 4.

- [ ] **Step 3: Create recipe template skeleton**

Write `lib/generators/strata/rules/templates/application_form/recipe.md.erb`:

````erb
---
paths:
  - "**/app/models/**/*application_form*.rb"
  - "**/app/controllers/**/*application_forms*.rb"
  - "**/spec/models/**/*application_form*_spec.rb"
  - "**/spec/requests/**/*application_forms*_spec.rb"
  - "**/spec/system/**/*application_form*_spec.rb"
---

# Strata SDK: ApplicationForm — Build Recipe

Step-by-step recipe for building a new application form end-to-end. Do steps in order. Each step: generate code, then test it, then commit.

## Overview

| Step | Action | Command / Deliverable |
|------|--------|----------------------|
| 1 | Generate model + migration | `bin/rails g strata:application_form NAME attr:type ...` |
| 2 | Test model | `spec/models/<name>_application_form_spec.rb` |
| 3 | Generate controller | `bin/rails g controller <Name>ApplicationForms ...` |
| 4 | Test controller | `spec/requests/<name>_application_forms_spec.rb` |
| 5 | Generate views | `bin/rails g strata:application_form_views Flow Form` |
| 6 | Test views | `spec/system/<name>_application_form_spec.rb` |

<!-- Step sections filled in subsequent tasks -->
````

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "recipe"`
Expected: 3 passes.

Run full file: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb`
Expected: all green. Specifically:
- The new monorepo `**/` test asserts every path entry in every generated rule starts with `**/`. The recipe template was written with `**/`-prefixed paths, and all existing templates already comply (verified in `application_form.md.erb`, `core-class.md.erb`, `attributes.md.erb`, `determinable.md.erb`, `views.md.erb`), so it passes.
- The existing "sub-files contain actual source code" test greps combined sub-file content for `/\b(def|class|module)\s+\w+/`. core-class/attributes/determinable still supply code. Passes.
- The existing "each sub-file is under 12,000 characters" test runs on recipe.md — the current template skeleton is ~800 chars. Passes.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/application_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add recipe.md.erb sub-rule skeleton with overview table"
```

---

## Task 2: Add Step 1 (generate model) and Step 2 (test model) sections

**Files:**
- Modify: `lib/generators/strata/rules/templates/application_form/recipe.md.erb`
- Test: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write the failing test**

Append inside the existing `describe "generating application_form"` block:

```ruby
it "recipe sub-file has Step 1 (generate model) and Step 2 (test model)" do
  content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
  expect(content).to include("## Step 1: Generate Application Form Model")
  expect(content).to include("bin/rails generate strata:application_form")
  expect(content).to include("## Step 2: Test Model")
  expect(content).to include("publish_event_with_payload")
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "Step 1"`
Expected: FAIL — sections not present.

- [ ] **Step 3: Append Step 1 + Step 2 sections to recipe template**

Replace the `<!-- Step sections filled in subsequent tasks -->` comment with:

````erb
## Step 1: Generate Application Form Model

Use `strata:application_form`. Appends `ApplicationForm` suffix if absent. Creates model file + migration. Merges base attributes (`status:integer`, `user_id:uuid`, `submitted_at:datetime`) automatically.

```bash
bin/rails generate strata:application_form Passport \
  name:name birth_date:memorable_date ssn:tax_id residential_address:address
```

Generated `app/models/passport_application_form.rb`:

```ruby
class PassportApplicationForm < Strata::ApplicationForm
  strata_attribute :name, :name
  strata_attribute :birth_date, :memorable_date
  strata_attribute :ssn, :tax_id
  strata_attribute :residential_address, :address
end
```

Column expansion per strata attribute: see `strata-application-form/attributes.md`.

Run migration:

```bash
bin/rails db:migrate
```

## Step 2: Test Model

File: `spec/models/passport_application_form_spec.rb`. Cover: persistence, round-trip read, submission publishes `{ClassName}Submitted` event, post-submission writes raise.

```ruby
# frozen_string_literal: true

require "rails_helper"
require "support/matchers/publish_event_with_payload"

RSpec.describe PassportApplicationForm do
  let(:form) { described_class.new(user_id: SecureRandom.uuid) }

  before do
    form.name_first = "John"
    form.name_last = "Doe"
    form.birth_date = { year: 1990, month: 1, day: 1 }
    form.save!
  end

  it "persists and round-trips strata attributes" do
    reloaded = described_class.find(form.id)
    expect(reloaded.name_first).to eq("John")
    expect(reloaded.birth_date).to eq(Date.new(1990, 1, 1))
  end

  it "publishes Submitted event on submission" do
    expect { form.submit_application }
      .to publish_event_with_payload(
        "PassportApplicationFormSubmitted",
        { application_form_id: form.id }
      )
  end

  it "prevents writes after submission" do
    form.submit_application
    expect(form.update(name_first: "Jane")).to be false
    expect(form.errors[:base]).to include("Cannot modify a submitted application")
  end
end
```

Run:

```bash
bundle exec rspec spec/models/passport_application_form_spec.rb
```

<!-- Step sections filled in subsequent tasks -->
````

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "Step 1"`
Expected: PASS.

Also run full spec file to confirm no regression: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb`
Expected: all green.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/application_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add Step 1 (model gen) and Step 2 (model spec) to recipe rule"
```

---

## Task 3: Add Step 3 (generate controller) and Step 4 (test controller) sections

**Files:**
- Modify: `lib/generators/strata/rules/templates/application_form/recipe.md.erb`
- Test: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write the failing test**

Append inside `describe "generating application_form"`:

```ruby
it "recipe sub-file has Step 3 (controller) and Step 4 (request spec)" do
  content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
  expect(content).to include("## Step 3: Generate Controller")
  expect(content).to include("bin/rails generate controller")
  expect(content).to include("submit_application")
  expect(content).to include("## Step 4: Test Controller")
  expect(content).to include('type: :request')
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "Step 3"`
Expected: FAIL.

- [ ] **Step 3: Append Step 3 + Step 4 sections**

Replace the trailing `<!-- Step sections filled in subsequent tasks -->` comment with:

````erb
## Step 3: Generate Controller

No Strata controller generator exists — use Rails' built-in generator, then customize actions to handle `submit_application` on `commit == "Submit"`. (Option C of the controller-generation design.)

```bash
bin/rails generate controller PassportApplicationForms index show new edit create update --skip-routes --no-helper
```

Add route in `config/routes.rb`:

```ruby
resources :passport_application_forms
```

Customize `app/controllers/passport_application_forms_controller.rb`:

The `create` action below does not handle submit-on-create — submission happens only on `update`, because a multi-page flow typically edits an existing `in_progress` record. If your flow lets users create-and-submit in one request, mirror the submit branch from `update` into `create`.

```ruby
# frozen_string_literal: true

class PassportApplicationFormsController < ApplicationController
  def index
    @passport_application_forms = PassportApplicationForm.all
  end

  def new
    @passport_application_form = PassportApplicationForm.new
  end

  def show
    @passport_application_form = PassportApplicationForm.find(params[:id])
  end

  def edit
    @passport_application_form = PassportApplicationForm.find(params[:id])
  end

  def create
    @passport_application_form = PassportApplicationForm.new(passport_application_form_params)

    if @passport_application_form.save
      redirect_to @passport_application_form, notice: "Application form was successfully saved."
    else
      flash.now[:errors] = @passport_application_form.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @passport_application_form = PassportApplicationForm.find(params[:id])

    if @passport_application_form.update(passport_application_form_params)
      if params[:commit] == "Submit"
        if @passport_application_form.submit_application
          redirect_to @passport_application_form, notice: "Application form was successfully submitted."
        else
          flash.now[:errors] = @passport_application_form.errors.full_messages
          render :edit, status: :unprocessable_entity
        end
      else
        redirect_to @passport_application_form, notice: "Application form was successfully updated."
      end
    else
      flash.now[:errors] = @passport_application_form.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def passport_application_form_params
    params.require(:passport_application_form).permit(
      :name_first, :name_middle, :name_last, :name_suffix,
      :ssn,
      :residential_address_street_line_1, :residential_address_street_line_2,
      :residential_address_city, :residential_address_state, :residential_address_zip_code,
      birth_date: [ :month, :day, :year ]
    )
  end
end
```

Strong-params note: strata attributes expand into underlying columns. Permit each underlying column (e.g., `name` → `name_first`, `name_middle`, `name_last`, `name_suffix`; `address` → `_street_line_1`, `_street_line_2`, `_city`, `_state`, `_zip_code`). `memorable_date` uses a nested hash (`month`, `day`, `year`). See `strata-application-form/attributes.md` for the full column map.

## Step 4: Test Controller

File: `spec/requests/passport_application_forms_spec.rb`. Cover each action happy path + the submit branch of `update`.

```ruby
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PassportApplicationForms", type: :request do
  let(:form) do
    PassportApplicationForm.create!(
      user_id: SecureRandom.uuid,
      name_first: "Jane",
      name_last: "Doe",
      birth_date: Date.new(1990, 1, 1)
    )
  end

  describe "GET /index" do
    it "renders" do
      get passport_application_forms_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "renders" do
      get passport_application_form_path(form)
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "renders" do
      get edit_passport_application_form_path(form)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /update" do
    it "updates and redirects to show" do
      patch passport_application_form_path(form),
            params: { passport_application_form: { name_first: "Jane" } }
      expect(response).to redirect_to(passport_application_form_path(form))
      expect(form.reload.name_first).to eq("Jane")
    end

    it "submits when commit=Submit" do
      patch passport_application_form_path(form),
            params: { passport_application_form: { name_first: "Jane", name_last: "Doe" },
                      commit: "Submit" }
      expect(form.reload.status).to eq("submitted")
    end

    it "re-renders edit with 422 when update invalid" do
      allow(PassportApplicationForm).to receive(:find).and_return(form)
      allow(form).to receive(:update).and_return(false)
      patch passport_application_form_path(form),
            params: { passport_application_form: { name_first: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
```

Run:

```bash
bundle exec rspec spec/requests/passport_application_forms_spec.rb
```

<!-- Step sections filled in subsequent tasks -->
````

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "Step 3"`
Expected: PASS.

Full file: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb` — all green.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/application_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add Step 3 (controller gen) and Step 4 (request spec) to recipe rule"
```

---

## Task 4: Add Step 5 (generate views) and Step 6 (test views) + Recap

**Files:**
- Modify: `lib/generators/strata/rules/templates/application_form/recipe.md.erb`
- Test: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write the failing test**

Append inside `describe "generating application_form"`:

```ruby
it "recipe sub-file has Step 5 (views) and Step 6 (view spec) and Recap" do
  content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
  expect(content).to include("## Step 5: Build Views")
  expect(content).to include("strata_form_with")
  expect(content).to include("## Step 6: Test Views")
  expect(content).to include("type: :system")
  expect(content).to include("## Recap")
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "Step 5"`
Expected: FAIL.

- [ ] **Step 3: Append Step 5 + Step 6 + Recap sections**

Replace the trailing `<!-- Step sections filled in subsequent tasks -->` comment with:

````erb
## Step 5: Build Views

Write the standard Rails views for the form under `app/views/passport_application_forms/`. Use the SDK's `strata_form_with` form builder — it wires the strata field helpers (`name`, `address_fields`, `memorable_date`, `tax_id_field`, etc.) to the expanded columns automatically. Field-helper reference: `strata-application-form/views.md`.

Minimum set:

- `index.html.erb` — list the user's in-progress and submitted forms
- `new.html.erb` — render form for creating a record
- `edit.html.erb` — render form for editing a saved record
- `show.html.erb` — read-only summary after submission

Example `app/views/passport_application_forms/edit.html.erb`:

```erb
<%= strata_form_with model: @passport_application_form do |f| %>
  <%= f.name :name %>
  <%= f.memorable_date :birth_date %>
  <%= f.tax_id_field :ssn %>
  <%= f.address_fields :residential_address %>

  <%= f.submit "Save" %>
  <%= f.submit "Submit" %>
<% end %>
```

Two submit buttons: clicking "Submit" sends `params[:commit] == "Submit"`, which the controller (Step 3) routes through `submit_application`. Clicking "Save" persists without submission.

> Multi-page flows (one question page per step, back/next navigation, step indicator) use `Strata::Flows::ApplicationFormController` and the `strata:application_form_views` generator — a different pattern than this recipe. See `strata-application-form/views.md` for that path.

## Step 6: Test Views

File: `spec/system/passport_application_form_spec.rb`. Capybara system spec walks the edit page and verifies form fields render and save.

```ruby
# frozen_string_literal: true

require "rails_helper"

RSpec.describe "PassportApplicationForm", type: :system do
  let(:form) do
    PassportApplicationForm.create!(
      user_id: SecureRandom.uuid,
      name_first: "Jane",
      name_last: "Doe",
      birth_date: Date.new(1990, 1, 1)
    )
  end

  it "renders the edit page with form fields" do
    visit edit_passport_application_form_path(form)
    expect(page).to have_field("passport_application_form[name_first]")
    expect(page).to have_field("passport_application_form[name_last]")
  end

  it "saves updates when Save is clicked" do
    visit edit_passport_application_form_path(form)
    fill_in "passport_application_form[name_first]", with: "John"
    click_button "Save"
    expect(form.reload.name_first).to eq("John")
  end
end
```

Run:

```bash
bundle exec rspec spec/system/passport_application_form_spec.rb
```

## Recap

Each step: generate → test → commit. Repeat. For deep dives, load these sibling sub-rules (they auto-load by path scope):

| Sub-rule | When it applies |
|----------|-----------------|
| `strata-application-form/core-class.md` | Editing model — submission internals, events |
| `strata-application-form/attributes.md` | Declaring `strata_attribute` — column mappings |
| `strata-application-form/views.md` | Editing views/layouts — field helpers, partials, I18n |
| `strata-application-form/determinable.md` | Recording a determination on the form |
````

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "Step 5"`
Expected: PASS.

Full file: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb` — all green.

Also verify 12k char limit still holds — the existing `each sub-file is under 12,000 characters` test must still pass.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/application_form/recipe.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Add Step 5 (views gen) and Step 6 (view spec) + Recap to recipe rule"
```

---

## Task 5: Surface recipe from root application_form.md.erb

**Files:**
- Modify: `lib/generators/strata/rules/templates/application_form.md.erb`
- Test: `spec/lib/generators/strata/generators/rules_generator_spec.rb`

- [ ] **Step 1: Write the failing test**

Append inside `describe "generating application_form"`:

```ruby
it "root file points to recipe as the build entry point" do
  content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form.md")
  expect(content).to include("Build Recipe")
  expect(content).to include("strata-application-form/recipe.md")
end
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "Build Recipe"`
Expected: FAIL.

- [ ] **Step 3: Edit root template to reference recipe**

In `lib/generators/strata/rules/templates/application_form.md.erb`, after the existing `## What is an Application Form?` section and before `## ApplicationForm Base Class`, insert:

```erb
## Build Recipe

Building a new application form = 6 steps: generate model, test model, generate controller, test controller, generate views, test views. Full recipe with commands + test templates:

→ **`strata-application-form/recipe.md`** (auto-loads when editing any application form file)

```

Also update the "Detailed Reference (Sub-rules)" table by adding a first row for the recipe:

```erb
| File | Contents |
|------|----------|
| `strata-sdk/strata-application-form/recipe.md` | Build recipe: 6-step gen→test workflow with commands and test templates |
| `strata-sdk/strata-application-form/core-class.md` | Full ApplicationForm source, event system, submission internals |
| `strata-sdk/strata-application-form/attributes.md` | Strata::Attributes module source, column mappings, attribute type details |
| `strata-sdk/strata-application-form/determinable.md` | Strata::Determinable source, recording determinations |
| `strata-sdk/strata-application-form/views.md` | Generated question-page templates, shared partials, index/show views, required I18n keys |
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb -e "Build Recipe"`
Expected: PASS.

Full file run: `bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb`
Expected: all green. Specifically verify the existing `root file is under 12,000 characters` test still passes — the recipe reference adds ~300 chars; root file was ~3.3k, comfortably under limit.

- [ ] **Step 5: Commit**

```bash
git add lib/generators/strata/rules/templates/application_form.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Link recipe sub-rule from root application_form rule"
```

---

## Task 6: Size check, monorepo check, lint, full suite

**Files:** verification only unless the 12 k limit is breached — then split per the contingency below.

- [ ] **Step 1: Measure rendered recipe size**

```bash
cd spec/dummy && bundle exec rails generate strata:rules application_form --force
wc -c .agents/rules/strata-sdk/strata-application-form/recipe.md
```

Expected: output < 12000 bytes. Estimated ≈ 8 900 chars based on the template content defined in Tasks 1–4.

If the number is ≥ 12 000, stop and apply the split contingency in Step 2. If < 12 000, skip Step 2 and go to Step 3.

- [ ] **Step 2: (Contingency) Split recipe into two sub-files**

Only execute if Step 1 showed overflow.

Split strategy: `recipe.md.erb` keeps Overview + Steps 1–4 (model + controller). New `recipe-views.md.erb` holds Steps 5–6 + Recap.

(a) Create `lib/generators/strata/rules/templates/application_form/recipe-views.md.erb` with the same frontmatter as `recipe.md.erb` (the five `**/`-prefixed path globs) and move the Step 5, Step 6, and Recap sections into it verbatim.

(b) In `recipe.md.erb`, delete Steps 5–6 and Recap and replace with a pointer:

```markdown
> Steps 5–6 (views generation + view specs) and the Recap live in the sibling rule `strata-application-form/recipe-views.md`, which auto-loads when editing view, layout, or system-spec files.
```

(c) Update root `application_form.md.erb` sub-rules table with a new row:

```erb
| `strata-sdk/strata-application-form/recipe-views.md` | Build recipe Steps 5–6: views generation and view specs |
```

(d) Add to `spec/lib/generators/strata/generators/rules_generator_spec.rb` inside the existing `describe "generating application_form"` block:

```ruby
it "creates the recipe-views split sub-file under 12k" do
  path = "#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe-views.md"
  expect(File.exist?(path)).to be true
  expect(File.size(path)).to be < 12_000
end

it "recipe.md points to recipe-views.md when split" do
  content = File.read("#{destination_root}/.agents/rules/strata-sdk/strata-application-form/recipe.md")
  expect(content).to include("strata-application-form/recipe-views.md")
end
```

Re-run Step 1 — both files must now be under 12 k.

- [ ] **Step 3: Run lint**

```bash
make lint
```

Expected: no offenses.

- [ ] **Step 4: Run the rules generator spec once more**

```bash
bundle exec rspec spec/lib/generators/strata/generators/rules_generator_spec.rb
```

Expected: all green. Verify the existing `each sub-file is under 12,000 characters` test (line 125) passes, and the new monorepo `**/` test passes.

- [ ] **Step 5: Run the full suite**

```bash
make test
```

Expected: all green.

- [ ] **Step 6: Regenerate the rules locally and eyeball them**

```bash
cd spec/dummy && bundle exec rails generate strata:rules application_form --force
```

Open the emitted files:
- `spec/dummy/.agents/rules/strata-sdk/strata-application-form/recipe.md`
- `spec/dummy/.agents/rules/strata-sdk/strata-application-form/recipe-views.md` (only if split)

Confirm: 6 steps present across the files, code blocks render, overview/recap tables render, no ERB artifacts bleeding through, every `paths:` entry starts with `**/`.

- [ ] **Step 7: Commit any contingency/lint changes**

```bash
git status    # verify only expected files are staged
git add lib/generators/strata/rules/templates/application_form/ \
        lib/generators/strata/rules/templates/application_form.md.erb \
        spec/lib/generators/strata/generators/rules_generator_spec.rb
git commit -m "Split recipe rule under 12k char limit"
```

Skip if no contingency was triggered and lint was already clean — no empty commits.

---

## Self-Review

**Spec coverage:**
- ✅ Recipe contains 6-step DSL for building application form — Tasks 1–4
- ✅ Step 1 = generate model + migration — Task 2
- ✅ Step 2 = test model via RSpec — Task 2
- ✅ Step 3 = generate controller — Task 3
- ✅ Step 4 = test controller — Task 3
- ✅ Step 5 = generate views — Task 4
- ✅ Step 6 = test views — Task 4
- ✅ Recipe lives in a sub-rule (`recipe.md`) — Task 1
- ✅ Root rule surfaces recipe prominently — Task 5

**Constraint coverage:**
- ✅ Monorepo `**/` path scoping enforced by new generator spec (Task 1) that walks every emitted rule file and asserts the prefix — catches drift on all rules, not just the new one.
- ✅ 12 000 char limit — existing test at `rules_generator_spec.rb:125` covers it. Task 6 Step 1 adds an explicit measurement and Step 2 defines a concrete split contingency (`recipe.md` + `recipe-views.md`) if the limit is ever breached.

**Placeholder scan:** No `TBD`, `TODO`, `implement later`, "similar to Task N" present. Every test, every recipe code block, every command is written out in full.

**Type/name consistency:**
- Template filename `recipe.md.erb` → output `recipe.md` — matches glob in `rules_generator.rb:79` (`*.md.erb` sorted).
- Sub-rule path `strata-sdk/strata-application-form/recipe.md` — matches existing output path convention (line 83).
- Form example uses `Passport` → transforms to `PassportApplicationForm` consistently across model, controller, spec, views, system spec.
- `publish_event_with_payload` matcher — matches existing dummy-app model spec at `spec/dummy/spec/models/passport_application_form_spec.rb:2`.
- I18n key `strata.form_builder.actions.save_and_continue` — matches the key documented in the existing views sub-rule template (`views.md.erb:138`).

---

## Execution Handoff

Plan complete and saved to `docs/superpowers/plans/2026-04-17-application-form-recipe-rule.md`. Two execution options:

**1. Subagent-Driven (recommended)** — I dispatch a fresh subagent per task, review between tasks, fast iteration.

**2. Inline Execution** — Execute tasks in this session using executing-plans, batch execution with checkpoints.

Which approach?
