# frozen_string_literal: true

require "rails/generators"

module Strata
  module Generators
    # Installs the durable events migration into the host application. Event
    # models and dispatch services are shipped by the engine; only the tables
    # need to be installed in the host database.
    #
    # @example Install the event outbox tables
    #   rails generate strata:events
    class EventsGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :"skip-migration-check", type: :boolean, default: false,
                                            desc: "Skip checking if the Strata event tables exist"

      def create_migration_file
        timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
        template "create_strata_events.rb.tt", "db/migrate/#{timestamp}_create_strata_events.rb"
      end

      def check_strata_event_tables
        return if options[:"skip-migration-check"]

        missing_tables = %i[strata_events strata_event_deliveries].reject do |table_name|
          ActiveRecord::Base.connection.table_exists?(table_name)
        end
        return if missing_tables.empty?

        table_label = "table".pluralize(missing_tables.size)
        verb = missing_tables.one? ? "does" : "do"
        say "Warning: #{missing_tables.join(' and ')} #{table_label} #{verb} not exist.", :yellow
        if yes?("Would you like to run 'bin/rails db:migrate' now? (y/n)")
          rails_command "db:migrate"
        else
          say "Run 'bin/rails db:migrate' before publishing Strata domain events.", :yellow
        end
      end
    end
  end
end
