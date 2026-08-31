# frozen_string_literal: true

require 'rails_helper'
require 'generators/strata/events/events_generator'
require 'fileutils'
require 'tmpdir'

RSpec.describe Strata::Generators::EventsGenerator, type: :generator do
  let(:destination_root) { Dir.mktmpdir }
  let(:options) { {} }
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
      allow(ActiveRecord::Base.connection).to receive(:table_exists?).and_return(true)
      generator.invoke_all
    end

    it 'creates one migration for both event tables' do
      migration_files = Dir.glob("#{destination_root}/db/migrate/*_create_strata_events.rb")
      expect(migration_files.size).to eq(1)
    end

    it 'does not create host model or job files' do
      expect(File.exist?("#{destination_root}/app/models/event.rb")).to be false
      expect(File.exist?("#{destination_root}/app/models/event_delivery.rb")).to be false
      expect(File.exist?("#{destination_root}/app/models/strata/event.rb")).to be false
      expect(File.exist?("#{destination_root}/app/models/strata/event_delivery.rb")).to be false
      expect(File.exist?("#{destination_root}/app/jobs/events/dispatch_job.rb")).to be false
      expect(File.exist?("#{destination_root}/app/jobs/strata/events/dispatch_job.rb")).to be false
    end
  end

  describe 'migration content' do
    let(:migration_content) do
      generator.invoke_all
      migration_file = Dir.glob("#{destination_root}/db/migrate/*_create_strata_events.rb").first
      File.read(migration_file)
    end

    before do
      allow(ActiveRecord::Base.connection).to receive(:table_exists?).and_return(true)
    end

    it 'creates both tables with UUID primary keys' do
      expect(migration_content).to include('create_table :strata_events, id: :uuid')
      expect(migration_content).to include('create_table :strata_event_deliveries, id: :uuid')
    end

    it 'defines the durable event fields' do
      expect(migration_content).to match(/t\.string\s+:name,\s+null:\s+false/)
      expect(migration_content).to match(/t\.jsonb\s+:payload,\s+null:\s+false,\s+default:\s+\{\}/)
      expect(migration_content).to include('t.string :correlation_id')
      expect(migration_content).to include('t.uuid :causation_id')
      expect(migration_content).to match(/t\.datetime\s+:occurred_at,\s+null:\s+false/)
      expect(migration_content).to include('t.datetime :dispatched_at')
      expect(migration_content).to include('t.datetime :next_attempt_at')
    end

    it 'defines per-handler delivery state' do
      expect(migration_content).to include('t.references :strata_event, null: false, type: :uuid, foreign_key: true')
      expect(migration_content).to match(/t\.string\s+:handler,\s+null:\s+false/)
      expect(migration_content).to match(/t\.integer\s+:status,\s+null:\s+false,\s+default:\s+0/)
      expect(migration_content).to match(/t\.integer\s+:attempts,\s+null:\s+false,\s+default:\s+0/)
      expect(migration_content).to include('t.datetime :next_attempt_at')
      expect(migration_content).to include('t.text :last_error')
    end

    it 'uses strings for polymorphic target identifiers' do
      expect(migration_content).to include('t.string :target_type')
      expect(migration_content).to include('t.string :target_id')
      expect(migration_content).not_to include('t.uuid :target_id')
    end

    it 'defines the dispatch and event-name indexes' do
      expect(migration_content).to include('add_index :strata_events, [ :dispatched_at, :next_attempt_at ]')
      expect(migration_content).to include('add_index :strata_events, [ :name, :occurred_at ]')
    end

    it 'defines the delivery idempotency and retry indexes' do
      expect(migration_content).to include('index_strata_event_deliveries_targetless_uniqueness')
      expect(migration_content).to include('index_strata_event_deliveries_targeted_uniqueness')
      expect(migration_content).to include('unique: true')
      expect(migration_content).to include('target_type IS NULL AND target_id IS NULL')
      expect(migration_content).to include('target_type IS NOT NULL AND target_id IS NOT NULL')
      expect(migration_content).not_to include('nulls_not_distinct: true')
      expect(migration_content).to include('add_index :strata_event_deliveries, [ :status, :next_attempt_at ]')
    end
  end

  describe 'table existence check' do
    it 'warns when either table does not exist and the user declines migration' do
      allow(ActiveRecord::Base.connection).to receive(:table_exists?) do |table_name|
        table_name == :strata_events
      end
      allow(generator).to receive(:yes?).and_return(false)
      allow(generator).to receive(:say)

      generator.invoke_all

      expect(generator).to have_received(:say).with(/strata_event_deliveries table does not exist/, :yellow)
    end

    it 'skips table checks when --skip-migration-check is set' do
      allow(ActiveRecord::Base.connection).to receive(:table_exists?)

      described_class.new([], { 'skip-migration-check': true, quiet: true },
                          destination_root: destination_root).invoke_all

      expect(ActiveRecord::Base.connection).not_to have_received(:table_exists?)
    end
  end
end
