# frozen_string_literal: true

require 'rails_helper'
require 'generators/strata/audit_log/audit_log_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Strata::Generators::AuditLogGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:options)          { {} }
  let(:generator) do
    described_class.new([], options.merge(quiet: true), destination_root: destination_root)
  end

  before do
    FileUtils.mkdir_p("#{destination_root}/db/migrate")
  end

  after do
    FileUtils.rm_rf(destination_root)
  end

  describe 'file creation' do
    before do
      allow(ActiveRecord::Base.connection).to receive(:table_exists?)
        .with(:strata_audit_lines).and_return(true)
      generator.invoke_all
    end

    it 'creates a migration file' do
      migration_file = Dir.glob("#{destination_root}/db/migrate/*_create_strata_audit_lines.rb").first
      expect(migration_file).to be_present
    end

    it 'does NOT create a host model file (engine ships the model directly)' do
      expect(File.exist?("#{destination_root}/app/models/audit_line.rb")).to be false
    end

    it 'does NOT create a host concern file (engine ships the concern directly)' do
      expect(File.exist?("#{destination_root}/app/models/concerns/auditable.rb")).to be false
    end

    it 'does NOT create host spec files' do
      expect(File.exist?("#{destination_root}/spec/models/audit_line_spec.rb")).to be false
      expect(File.exist?("#{destination_root}/spec/models/concerns/auditable_spec.rb")).to be false
    end
  end

  describe 'migration content' do
    let(:migration_content) do
      generator.invoke_all
      migration_file = Dir.glob("#{destination_root}/db/migrate/*_create_strata_audit_lines.rb").first
      File.read(migration_file)
    end

    before do
      allow(ActiveRecord::Base.connection).to receive(:table_exists?)
        .with(:strata_audit_lines).and_return(true)
    end

    it 'creates the strata_audit_lines table with a UUID primary key' do
      expect(migration_content).to include('create_table :strata_audit_lines, id: :uuid')
    end

    it 'declares a NOT NULL action column' do
      expect(migration_content).to match(/t\.string\s+:action,\s+null:\s+false/)
    end

    it 'declares polymorphic subject columns (both nullable)' do
      expect(migration_content).to include(':subject_id')
      expect(migration_content).to include(':subject_type')
    end

    it 'declares polymorphic actor columns (both nullable)' do
      expect(migration_content).to include(':actor_id')
      expect(migration_content).to include(':actor_type')
    end

    it 'declares a NOT NULL jsonb data column with default {}' do
      expect(migration_content).to match(/t\.jsonb\s+:data,\s+null:\s+false,\s+default:\s+\{\}/)
    end

    it 'declares created_at without updated_at (audit lines are immutable)' do
      expect(migration_content).to include(':created_at')
      expect(migration_content).not_to include(':updated_at')
      expect(migration_content).not_to include('t.timestamps')
    end

    it 'declares the composite subject + created_at index' do
      expect(migration_content).to include('index_strata_audit_lines_on_subject_and_created_at')
    end

    it 'declares the composite actor index' do
      expect(migration_content).to include('index_strata_audit_lines_on_polymorphic_actor')
    end
  end

  describe 'table existence check' do
    it 'warns when the table does not exist and the user declines migration' do
      allow(ActiveRecord::Base.connection).to receive(:table_exists?)
        .with(:strata_audit_lines).and_return(false)
      allow(generator).to receive(:yes?).and_return(false)
      allow(generator).to receive(:say)

      generator.invoke_all

      expect(generator).to have_received(:say).with(/strata_audit_lines table does not exist/, :yellow)
    end

    it 'skips the table check when --skip-migration-check is set' do
      allow(generator).to receive(:say)
      allow(ActiveRecord::Base.connection).to receive(:table_exists?)

      described_class.new([], { 'skip-migration-check': true, quiet: true },
                         destination_root: destination_root).invoke_all

      expect(ActiveRecord::Base.connection).not_to have_received(:table_exists?)
        .with(:strata_audit_lines)
    end
  end
end
