# frozen_string_literal: true

require "rails/generators"

module Strata
  module Generators
    # Generator that installs the strata_audit_lines migration into the host
    # application. The model, concern, and API class are shipped by the engine
    # directly — only the migration needs to be copied because Rails engines
    # don't auto-load engine migrations.
    #
    # @example Install the audit log migration
    #   rails generate strata:audit_log
    class AuditLogGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      class_option :"skip-migration-check", type: :boolean, default: false,
                                            desc: "Skip checking if strata_audit_lines table exists"

      def create_migration_file
        timestamp = Time.now.utc.strftime("%Y%m%d%H%M%S")
        template "create_strata_audit_lines.rb.tt", "db/migrate/#{timestamp}_create_strata_audit_lines.rb"
      end

      def check_strata_audit_lines_table
        return if options[:"skip-migration-check"]
        return if ActiveRecord::Base.connection.table_exists?(:strata_audit_lines)

        say "Warning: strata_audit_lines table does not exist.", :yellow
        if yes?("Would you like to run 'bin/rails db:migrate' now? (y/n)")
          rails_command "db:migrate"
        else
          say "You may need to run 'bin/rails db:migrate' before using Strata::AuditLog.", :yellow
        end
      end
    end
  end
end
