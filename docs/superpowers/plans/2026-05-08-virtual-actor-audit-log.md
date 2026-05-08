# Virtual Actor Audit Log Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Enable `Strata::AuditLine` to record and retrieve non-ActiveRecord (virtual) actors so host apps can audit "the system did this" without forcing a DB row.

**Architecture:** Reuse the existing polymorphic `actor_id`/`actor_type` columns. Introduce a `Strata::VirtualActor` marker module that host apps mix into non-AR actor classes, and a `Strata::VirtualActor::Instance` value object returned on read. Override `AuditLine#actor=`, `#actor`, and the `by_actor` scope so virtual actors round-trip and remain queryable. No DB migration.

**Tech Stack:** Rails 7, ActiveRecord, RSpec, FactoryBot, RuboCop. UUID PKs. Existing `Strata::ValueObject` base for value objects.

**Source spec:** `docs/superpowers/specs/2026-05-08-virtual-actor-audit-log-design.md`

---

## File Structure

| File | Purpose | Created/Modified |
|------|---------|------------------|
| `app/models/strata/virtual_actor.rb` | Marker module + nested `Instance` value object | Create |
| `app/models/strata/audit_line.rb` | Override `actor=`, `actor`, `by_actor` | Modify |
| `spec/dummy/app/models/test_virtual_actor.rb` | Test fixture: a class including `Strata::VirtualActor` | Create |
| `spec/models/strata/virtual_actor_spec.rb` | Specs for the module + `Instance` value object | Create |
| `spec/models/strata/audit_line_spec.rb` | Add virtual-actor write/read/scope specs | Modify |
| `spec/factories/strata/strata_audit_line_factory.rb` | Add `:with_virtual_actor` trait | Modify |

`Strata::VirtualActor::Instance` extends `Strata::ValueObject` (`app/models/strata/value_object.rb`) — that base class already provides value-equality, immutability semantics, `#blank?`, `#persisted? => false`, and ActiveModel attribute support. Do **not** hand-roll a new value-object base.

---

## Conventions (read once before starting)

- **Test runner:** `make test` runs the full suite; `bundle exec rspec <path>` runs a single file. Run from the repo root.
- **Linter:** `make lint` (auto-fix) or `make lint-ci` (check only).
- **Commit style:** short imperative subject lines, no Conventional Commits prefix. Examples from `git log`: "Add design spec for virtual actor audit log support", "Be explicit about attributes on Strata::AuditLine". Match this style.
- **DB:** UUIDs everywhere; the `actor_id` column already exists as `uuid` (`spec/dummy/db/schema.rb:66`). No migration needed.
- **Test fixtures live in `spec/dummy/app/models/`** (e.g. `test_application_form.rb`). Rails autoloads them in the dummy app — no `require` needed in specs.
- The current branch is `baonguyen/add-audit-log`. Stay on it.

---

## Task 1: Add the `Strata::VirtualActor` module + `Instance` value object

**Files:**
- Create: `app/models/strata/virtual_actor.rb`
- Create: `spec/models/strata/virtual_actor_spec.rb`

This is foundational — every later task depends on the module and the `Instance` class existing. Build it first, with tests, before touching `AuditLine`.

- [ ] **Step 1: Write the failing spec**

Create `spec/models/strata/virtual_actor_spec.rb` with the following content:

```ruby
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Strata::VirtualActor do
  describe 'as a marker module' do
    let(:virtual_class) do
      Class.new do
        include Strata::VirtualActor
      end
    end

    it 'is includable in any class without requiring methods' do
      expect(virtual_class.include?(described_class)).to be true
    end

    it 'adds no instance methods to the including class' do
      original_methods = Class.new.instance_methods
      expect(virtual_class.instance_methods - original_methods).to be_empty
    end
  end

  describe Strata::VirtualActor::Instance do
    subject(:instance) { described_class.new(actor_type: 'Api::Client') }

    describe '#actor_type' do
      it 'returns the type string passed in' do
        expect(instance.actor_type).to eq('Api::Client')
      end
    end

    describe '#display_name' do
      it 'demodulizes and humanizes the type' do
        expect(instance.display_name).to eq('Client')
      end

      it 'humanizes a snake_case suffix' do
        other = described_class.new(actor_type: 'Cron::DailyWorker')
        expect(other.display_name).to eq('Daily worker')
      end
    end

    describe '#==' do
      it 'is equal to another Instance with the same actor_type' do
        other = described_class.new(actor_type: 'Api::Client')
        expect(instance).to eq(other)
      end

      it 'is not equal to an Instance with a different actor_type' do
        other = described_class.new(actor_type: 'Cron::Worker')
        expect(instance).not_to eq(other)
      end

      it 'is not equal to an arbitrary object with a matching actor_type method' do
        impostor = Struct.new(:actor_type).new('Api::Client')
        expect(instance).not_to eq(impostor)
      end
    end

    describe '#persisted?' do
      it 'is false (it has no DB row)' do
        expect(instance.persisted?).to be false
      end
    end
  end
end
```

- [ ] **Step 2: Run the spec and confirm it fails**

Run: `bundle exec rspec spec/models/strata/virtual_actor_spec.rb`
Expected: load error or `NameError: uninitialized constant Strata::VirtualActor`.

- [ ] **Step 3: Create the module + Instance**

Create `app/models/strata/virtual_actor.rb`:

```ruby
# frozen_string_literal: true

module Strata
  # Marker module host apps include in non-ActiveRecord actor classes so
  # `Strata::AuditLine` can persist and round-trip them via the polymorphic
  # `actor_type` column. No methods are required on the including class.
  #
  # @example
  #   class Api::Client
  #     include Strata::VirtualActor
  #   end
  #
  #   Strata::AuditLog.write!(action: "system.synced", actor: Api::Client.new)
  module VirtualActor
    # Immutable value object returned by `Strata::AuditLine#actor` when the
    # underlying row stores a virtual actor (actor_id IS NULL, actor_type
    # names a class that includes Strata::VirtualActor).
    #
    # Identity is the class name only — per-instance state on the original
    # virtual actor is not persisted.
    class Instance < Strata::ValueObject
      attribute :actor_type, :string

      def display_name
        actor_type.to_s.demodulize.underscore.humanize
      end
    end
  end
end
```

The base `Strata::ValueObject#==` already returns false for a different class, and compares each attribute by value, which is the behavior the spec asserts.

- [ ] **Step 4: Run the spec and confirm it passes**

Run: `bundle exec rspec spec/models/strata/virtual_actor_spec.rb`
Expected: all examples pass.

- [ ] **Step 5: Lint**

Run: `make lint`
Expected: no offenses, or only auto-fixed style issues. If RuboCop reports unfixable warnings, address them in the source before committing.

- [ ] **Step 6: Commit**

```bash
git add app/models/strata/virtual_actor.rb spec/models/strata/virtual_actor_spec.rb
git commit -m "Add Strata::VirtualActor module and Instance value object"
```

---

## Task 2: Add a test virtual-actor fixture class

**Files:**
- Create: `spec/dummy/app/models/test_virtual_actor.rb`

The audit_line specs in later tasks need a real Ruby class that includes `Strata::VirtualActor`. Defining it in `spec/dummy/app/models/` makes it autoloadable from any spec — same pattern as `TestApplicationForm`.

- [ ] **Step 1: Create the fixture**

Create `spec/dummy/app/models/test_virtual_actor.rb`:

```ruby
# frozen_string_literal: true

# Test-only virtual actor used by audit-log specs and factories. Mirrors how a
# host app would mark a non-ActiveRecord actor class.
class TestVirtualActor
  include Strata::VirtualActor
end
```

- [ ] **Step 2: Verify autoload works**

Run: `cd spec/dummy && bundle exec rails runner "puts TestVirtualActor.include?(Strata::VirtualActor)"`
Expected output: `true`

- [ ] **Step 3: Commit**

```bash
git add spec/dummy/app/models/test_virtual_actor.rb
git commit -m "Add TestVirtualActor fixture for audit log specs"
```

---

## Task 3: Add `:with_virtual_actor` factory trait

**Files:**
- Modify: `spec/factories/strata/strata_audit_line_factory.rb`

A trait keeps virtual-actor specs concise and exercises the `actor=` override the same way real callers will.

- [ ] **Step 1: Read the current factory**

Current contents (`spec/factories/strata/strata_audit_line_factory.rb`):

```ruby
# frozen_string_literal: true

FactoryBot.define do
  factory :strata_audit_line, class: 'Strata::AuditLine' do
    action { 'test.event' }
    subject { nil }
    actor { nil }
    data { {} }
  end
end
```

- [ ] **Step 2: Add the trait**

Replace the file with:

```ruby
# frozen_string_literal: true

FactoryBot.define do
  factory :strata_audit_line, class: 'Strata::AuditLine' do
    action { 'test.event' }
    subject { nil }
    actor { nil }
    data { {} }

    trait :with_virtual_actor do
      actor { TestVirtualActor.new }
    end
  end
end
```

- [ ] **Step 3: Smoke-test the trait (no implementation yet, so persistence will fail with the current `actor=`)**

This step is intentionally deferred — at this point in the plan, `AuditLine#actor=` does not yet treat virtual actors specially, so `create(:strata_audit_line, :with_virtual_actor)` will hit the AR polymorphic setter and likely raise. That's expected. The trait will start working in Task 4.

Run: `bundle exec rspec spec/models/strata/virtual_actor_spec.rb`
Expected: still passes (we did not touch that spec).

- [ ] **Step 4: Commit**

```bash
git add spec/factories/strata/strata_audit_line_factory.rb
git commit -m "Add :with_virtual_actor trait to strata_audit_line factory"
```

---

## Task 4: Override `AuditLine#actor=` for virtual actors

**Files:**
- Modify: `app/models/strata/audit_line.rb`
- Modify: `spec/models/strata/audit_line_spec.rb`

Drive write-side behavior with tests first. Cover four cases: AR actor (unchanged), virtual instance, virtual class, nil.

- [ ] **Step 1: Add failing write-side specs**

Open `spec/models/strata/audit_line_spec.rb`. Find the existing `describe 'polymorphic actor'` block (currently around lines 34–49). Replace that whole block with:

```ruby
  describe 'polymorphic actor' do
    let(:user) { create(:user) }

    it 'stores and retrieves an ActiveRecord actor' do
      line = create(:strata_audit_line, actor: user)
      expect(line.actor).to eq(user)
      expect(line.actor_type).to eq('User')
      expect(line.actor_id).to eq(user.id)
    end

    it 'allows nil actor' do
      line = build(:strata_audit_line, actor: nil)
      expect(line).to be_valid
      expect { line.save! }.not_to raise_error
      expect(line.actor_type).to be_nil
      expect(line.actor_id).to be_nil
    end
  end

  describe 'virtual actor write side' do
    it 'stores actor_type and leaves actor_id nil when given a virtual actor instance' do
      line = create(:strata_audit_line, actor: TestVirtualActor.new)
      expect(line.actor_type).to eq('TestVirtualActor')
      expect(line.actor_id).to be_nil
    end

    it 'treats a virtual actor class identically to an instance' do
      line = create(:strata_audit_line, actor: TestVirtualActor)
      expect(line.actor_type).to eq('TestVirtualActor')
      expect(line.actor_id).to be_nil
    end

    it 'clears actor_type and actor_id when reassigned to nil' do
      line = build(:strata_audit_line, actor: TestVirtualActor.new)
      line.actor = nil
      expect(line.actor_type).to be_nil
      expect(line.actor_id).to be_nil
    end

    it 'does not include a virtual actor as an AR record' do
      line = create(:strata_audit_line, actor: TestVirtualActor.new)
      expect(line.actor_id).to be_nil
      # Sanity: no constant lookup or DB hit happened — actor_id stays nil.
    end

    it 'accepts a VirtualActor::Instance returned from a previous read' do
      original = create(:strata_audit_line, actor: TestVirtualActor.new)
      instance = original.reload.actor
      expect(instance).to be_a(Strata::VirtualActor::Instance)

      copy = create(:strata_audit_line, actor: instance)
      expect(copy.actor_type).to eq('TestVirtualActor')
      expect(copy.actor_id).to be_nil
    end
  end
```

The last example proves round-trip symmetry: `line2.actor = line1.actor` must not silently corrupt the row by writing `"Strata::VirtualActor::Instance"` into `actor_type`. Without an `Instance` branch in `actor=`, the override falls through to AR (Instance does not include the marker by design) and breaks.

- [ ] **Step 2: Run the specs and confirm the new ones fail**

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb -e "virtual actor write side"`
Expected: failures. Most likely: `actor_id` ends up set to something non-nil, or AR raises trying to read `id` on the virtual actor.

- [ ] **Step 3: Override `actor=`**

Open `app/models/strata/audit_line.rb`. Currently:

```ruby
# frozen_string_literal: true

module Strata
  class AuditLine < ApplicationRecord
    self.table_name = "strata_audit_lines"

    belongs_to :subject, polymorphic: true, optional: true
    belongs_to :actor,   polymorphic: true, optional: true

    attribute :action,     :string
    attribute :data,       :jsonb, default: {}
    attribute :created_at, :datetime

    validates :action, presence: true

    scope :for_subject,  ->(subject) { where(subject: subject) }
    scope :by_actor,     ->(actor)   { where(actor: actor) }
    scope :with_action,  ->(action)  { where(action: action.to_s) }
    scope :latest_first, -> { order(created_at: :desc) }

    def readonly?
      persisted?
    end
  end
end
```

Add an `actor=` override below the `readonly?` method (still inside the class). The override must handle four input shapes: nil (delegate), a `VirtualActor::Instance` returned from a previous read (use its `actor_type`), a virtual actor class or instance (use the class name), or any other value (delegate to AR's polymorphic setter):

```ruby
    def actor=(value)
      return super if value.nil?

      if value.is_a?(Strata::VirtualActor::Instance)
        self.actor_type = value.actor_type
        self.actor_id   = nil
        return value
      end

      klass = value.is_a?(Class) ? value : value.class
      if klass.include?(Strata::VirtualActor)
        self.actor_type = klass.name
        self.actor_id   = nil
      else
        super
      end
    end
```

- [ ] **Step 4: Run the write-side specs and confirm they pass**

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb -e "virtual actor write side"`
Expected: all four examples pass.

Also re-run the existing AR-actor block to confirm no regression:

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb -e "polymorphic actor"`
Expected: both examples pass.

- [ ] **Step 5: Commit**

```bash
git add app/models/strata/audit_line.rb spec/models/strata/audit_line_spec.rb
git commit -m "Override Strata::AuditLine#actor= to support virtual actors"
```

---

## Task 5: Override `AuditLine#actor` (read side)

**Files:**
- Modify: `app/models/strata/audit_line.rb`
- Modify: `spec/models/strata/audit_line_spec.rb`

The read side has four cases (the matrix in the spec). Cover each.

- [ ] **Step 1: Add failing read-side specs**

In `spec/models/strata/audit_line_spec.rb`, after the `describe 'virtual actor write side'` block from Task 4, insert:

```ruby
  describe 'virtual actor read side' do
    it 'returns a VirtualActor::Instance when actor_id is nil and actor_type names a virtual class' do
      line = create(:strata_audit_line, actor: TestVirtualActor.new)

      result = line.reload.actor
      expect(result).to be_a(Strata::VirtualActor::Instance)
      expect(result.actor_type).to eq('TestVirtualActor')
    end

    it 'returns nil when actor_id is nil and actor_type names a non-virtual (deleted AR) class' do
      line = build(:strata_audit_line)
      line.actor_type = 'User'
      line.actor_id = nil
      line.save!

      expect(line.reload.actor).to be_nil
    end

    it 'returns nil when actor_id is nil and actor_type names a class that no longer exists' do
      line = build(:strata_audit_line)
      line.actor_type = 'NoSuchClass'
      line.actor_id = nil
      line.save!

      expect(line.reload.actor).to be_nil
    end

    it 'returns the AR record when actor_id is present (unchanged behavior)' do
      user = create(:user)
      line = create(:strata_audit_line, actor: user)

      expect(line.reload.actor).to eq(user)
    end

    it 'returns nil when both actor_id and actor_type are nil (unchanged behavior)' do
      line = create(:strata_audit_line, actor: nil)
      expect(line.reload.actor).to be_nil
    end
  end
```

- [ ] **Step 2: Run the specs and confirm the new ones fail**

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb -e "virtual actor read side"`
Expected: at least the first example fails — without the read override, `line.actor` triggers `TestVirtualActor.find(nil)` (NoMethodError) or returns nil.

- [ ] **Step 3: Override `actor`**

In `app/models/strata/audit_line.rb`, add the reader override directly above the `actor=` override added in Task 4:

```ruby
    def actor
      return super unless actor_type.present? && actor_id.nil?

      klass = actor_type.safe_constantize
      return nil unless klass&.include?(Strata::VirtualActor)

      Strata::VirtualActor::Instance.new(actor_type: actor_type)
    end
```

The full pair (`actor`, `actor=`) should now sit together below `readonly?` in the class.

- [ ] **Step 4: Run the read-side specs and confirm they pass**

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb -e "virtual actor read side"`
Expected: all five examples pass.

Re-run the full file to catch regressions in unrelated specs:

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb`
Expected: green.

- [ ] **Step 5: Commit**

```bash
git add app/models/strata/audit_line.rb spec/models/strata/audit_line_spec.rb
git commit -m "Override Strata::AuditLine#actor to return VirtualActor::Instance"
```

---

## Task 6: Update `by_actor` scope to handle three input shapes

**Files:**
- Modify: `app/models/strata/audit_line.rb`
- Modify: `spec/models/strata/audit_line_spec.rb`

The scope must accept (a) AR records, (b) virtual classes/instances, (c) `VirtualActor::Instance` returned by a previous read.

- [ ] **Step 1: Add failing scope specs**

In `spec/models/strata/audit_line_spec.rb`, find the existing `describe '.by_actor'` block (currently nested inside `describe 'scopes'`). Replace its body with:

```ruby
    describe '.by_actor' do
      it 'returns only lines for the given AR actor' do
        expect(described_class.by_actor(user_alpha))
          .to contain_exactly(line_alpha_created, line_bravo_created)
      end

      context 'with a virtual actor' do
        let!(:virtual_line)    { create(:strata_audit_line, :with_virtual_actor, action: 'system.synced') }
        let!(:other_virtual)   { create(:strata_audit_line, actor_type: 'Other::System', actor_id: nil, action: 'other') }

        it 'returns lines stored by a virtual actor instance' do
          expect(described_class.by_actor(TestVirtualActor.new))
            .to contain_exactly(virtual_line)
        end

        it 'returns lines stored by a virtual actor class' do
          expect(described_class.by_actor(TestVirtualActor))
            .to contain_exactly(virtual_line)
        end

        it 'returns lines when passed a VirtualActor::Instance read from another line' do
          read_actor = virtual_line.reload.actor
          expect(read_actor).to be_a(Strata::VirtualActor::Instance)

          expect(described_class.by_actor(read_actor))
            .to contain_exactly(virtual_line)
        end

        it 'does not match AR-actor rows when querying for a virtual actor' do
          expect(described_class.by_actor(TestVirtualActor))
            .not_to include(line_alpha_created)
        end
      end
    end
```

The `other_virtual` row uses raw `actor_type`/`actor_id` writes to bypass the override — this is intentional, simulating a row whose class is not `TestVirtualActor`, so the scope's class-filter is exercised.

- [ ] **Step 2: Run the new specs and confirm they fail**

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb -e "by_actor"`
Expected: the AR case still passes; the four virtual cases fail because the existing scope produces wrong SQL (`actor_type='TestVirtualActor' AND actor_id='<some uuid>'` for instances with `id` undefined, or matches the wrong rows).

- [ ] **Step 3: Replace the scope**

In `app/models/strata/audit_line.rb`, replace:

```ruby
    scope :by_actor,     ->(actor)   { where(actor: actor) }
```

with:

```ruby
    scope :by_actor, ->(actor) {
      case actor
      when Strata::VirtualActor::Instance
        where(actor_type: actor.actor_type, actor_id: nil)
      else
        klass = actor.is_a?(Class) ? actor : actor.class
        if klass.include?(Strata::VirtualActor)
          where(actor_type: klass.name, actor_id: nil)
        else
          where(actor: actor)
        end
      end
    }
```

- [ ] **Step 4: Run the scope specs and confirm they pass**

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb -e "by_actor"`
Expected: all examples pass (AR case + four virtual cases).

- [ ] **Step 5: Commit**

```bash
git add app/models/strata/audit_line.rb spec/models/strata/audit_line_spec.rb
git commit -m "Extend Strata::AuditLine.by_actor to handle virtual actors"
```

---

## Task 7: Verify end-to-end through `AuditLog.record` and `AuditLog.write!`

**Files:**
- Modify: `spec/models/strata/audit_line_spec.rb`

The spec asserts that the public `AuditLog.record` and `AuditLog.write!` entry points need no changes — prove it.

- [ ] **Step 1: Add an integration spec**

In `spec/models/strata/audit_line_spec.rb`, after the `describe 'virtual actor read side'` block from Task 5, insert:

```ruby
  describe 'integration with Strata::AuditLog' do
    it 'records a virtual actor through AuditLog.write!' do
      line = Strata::AuditLog.write!(action: 'system.synced', actor: TestVirtualActor.new)

      expect(line.actor_type).to eq('TestVirtualActor')
      expect(line.actor_id).to be_nil
      expect(line.reload.actor).to be_a(Strata::VirtualActor::Instance)
    end

    it 'records a virtual actor as the default actor in AuditLog.record' do
      log = Strata::AuditLog.record(actor: TestVirtualActor.new) do |l|
        l.add_line(action: 'system.tick')
      end

      line = log.lines.first
      expect(line.actor_type).to eq('TestVirtualActor')
      expect(line.actor_id).to be_nil
      expect(line.reload.actor).to be_a(Strata::VirtualActor::Instance)
    end
  end
```

- [ ] **Step 2: Run the integration spec**

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb -e "integration with Strata::AuditLog"`
Expected: both examples pass without any code changes — the entry points already pass `actor:` straight through to `AuditLine.create!`.

If they fail: stop and re-read `app/models/strata/audit_log.rb` to find where the actor is being mutated before it reaches `actor=`. Do not modify `audit_log.rb` to "fix" it — the spec calls for no changes there. A failure here means an earlier task introduced a regression.

- [ ] **Step 3: Commit**

```bash
git add spec/models/strata/audit_line_spec.rb
git commit -m "Cover virtual actor end-to-end through Strata::AuditLog"
```

---

## Task 8: Final sweep — full suite, lint, and existing audit_log tests

**Files:**
- None (verification only)

- [ ] **Step 1: Run the full audit-log spec set**

Run: `bundle exec rspec spec/models/strata/audit_line_spec.rb spec/models/strata/audit_log_spec.rb spec/models/strata/virtual_actor_spec.rb spec/models/concerns/strata/auditable_spec.rb`
Expected: all green.

- [ ] **Step 2: Run the full project test suite**

Run: `make test`
Expected: all green. If anything else broke, the most likely culprit is the `actor=` or `actor` override interacting with a spec that constructs `AuditLine` rows by hand — investigate and fix without weakening the new behavior.

- [ ] **Step 3: Lint everything**

Run: `make lint-ci`
Expected: no offenses. If RuboCop complains about the lambda syntax (`->(actor) { ... }` vs `lambda { |actor| ... }`) match whatever the existing scopes use — current style in `audit_line.rb` is `->(...)`, keep that.

- [ ] **Step 4: Review the diff against the spec one more time**

Run: `git diff main -- app/models/strata/`
Quick checklist:
- `actor=` returns early on nil
- `actor=` accepts both class and instance
- `actor` falls through to `super` when the row is an AR actor
- `actor` returns nil for the deleted-AR case (class exists but does not include VirtualActor) AND for the missing-class case (`safe_constantize` returns nil)
- `by_actor` handles all three input shapes (AR record, virtual class/instance, `VirtualActor::Instance`)
- No migration was added (`git diff main -- spec/dummy/db/` should show no schema or migration changes)

- [ ] **Step 5: No commit needed** — Task 8 is verification only. If issues surfaced and you fixed them, commit those fixes individually with descriptive messages.

---

## Done

At the end of Task 8 the branch should have 6 new commits on top of the spec commit:

1. Add `Strata::VirtualActor` module and `Instance` value object
2. Add `TestVirtualActor` fixture for audit log specs
3. Add `:with_virtual_actor` trait to `strata_audit_line` factory
4. Override `Strata::AuditLine#actor=` to support virtual actors
5. Override `Strata::AuditLine#actor` to return `VirtualActor::Instance`
6. Extend `Strata::AuditLine.by_actor` to handle virtual actors
7. Cover virtual actor end-to-end through `Strata::AuditLog`

Total: ~80 lines of production code in two files (`virtual_actor.rb`, `audit_line.rb`) plus tests, fixture, and factory trait. Zero migrations.
