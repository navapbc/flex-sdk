require "rails/generators"

module Strata
  module Generators
    # Generator for creating Strata::Task subclasses with standardized templates.
    # Supports custom parent classes and database migration checking.
    class TaskGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :parent, type: :string, desc: "The parent class for the generated task"
      class_option :"skip-migration-check", type: :boolean, default: false, desc: "Skip checking if flex_tasks table exists"

      def initialize(*args, &block)
        super
        @task_name = format_task_name(name)
        @parent_class = options[:parent] || "Strata::Task"
      end

      def create_task_file
        template "task.rb", File.join("app/models", "#{file_path}.rb")
      end

      def create_test_file
        template "task_spec.rb", File.join("spec/models", "#{file_path}_spec.rb")
      end

      def check_flex_tasks_table
        return if options[:"skip-migration-check"]

        unless ActiveRecord::Base.connection.table_exists?(:flex_tasks)
          say "Warning: flex_tasks table does not exist.", :yellow
          if yes?("Would you like to install and run Flex migrations now? (y/n)")
            rails_command "strata:install:migrations"
            rails_command "db:migrate"
          else
            say "You may need to run 'bin/rails strata:install:migrations' and 'bin/rails db:migrate' before using your task class.", :yellow
          end
        end
      end

      private

      def format_task_name(name)
        formatted = name.underscore.classify
        formatted.end_with?("Task") ? formatted : "#{formatted}Task"
      end

      def file_path
        @task_name.underscore
      end
    end
  end
end
