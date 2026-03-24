# frozen_string_literal: true

module Strata
  module Tasks
    # TaskRowComponent renders one row of the tasks index table. Host apps can subclass
    # and override {.columns}, {.header_translation_for}, {.header_options_for}, and
    # column instance methods to add or reorder columns.
    #
    # @example Default usage (from +strata/tasks/index+)
    #   <%= render TaskRowComponent.new(task: task) %>
    #
    class TaskRowComponent < ViewComponent::Base
      def initialize(task:, **)
        @task = task
      end

      def self.columns
        %i[due_date type case_id created_date]
      end

      def self.headers
        columns.map { |column| header_translation_for(column) }
      end

      def self.header_translation_for(column)
        I18n.t("strata.tasks.index.columns.col_#{column}")
      end

      def self.header_options_for(column)
        return { aria_sort: "descending" } if column == :created_date

        {}
      end

      def row_classes
        nil
      end

      protected

      def due_date
        helpers.local_en_us(@task.due_on)
      end

      def type
        link_to I18n.t("tasks.types.#{@task.type.underscore}"),
                helpers.url_for(only_path: true, action: :show, id: @task.id.to_s)
      end

      def case_id
        @task.case_id
      end

      def created_date
        helpers.local_en_us(@task.created_at.to_date)
      end

      def sort_value_for(column)
        case column.to_sym
        when :due_date
          helpers.time_since_epoch(@task.due_on)
        when :type
          @task.type
        when :case_id
          @task.case_id
        when :created_date
          helpers.time_since_epoch(@task.created_at)
        else
          nil
        end
      end

      def cell_classes(_column)
        nil
      end

      def cell_html_options(column)
        attrs = {}
        sv = sort_value_for(column)
        attrs[:data] = { sort_value: sv } unless sv.nil?
        cc = cell_classes(column)
        attrs[:class] = cc if cc.present?
        attrs
      end
    end
  end
end
