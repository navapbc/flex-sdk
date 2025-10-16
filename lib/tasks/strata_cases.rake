# frozen_string_literal: true

require_relative "strata_task_helpers"

namespace :strata do
  namespace :cases do
    extend StrataTaskHelpers

    desc "Migrate Case#business_process_current_step from one step name to another"
    task :migrate_business_process_current_step, [ :case_class_name, :from_step_name, :to_step_name ] => [ :environment ] do |t, args|
      case_class_name, from_step_name, to_step_name = *fetch_required_args!(args, :case_class_name, :from_step_name, :to_step_name)
      case_class = constantize_case_class(case_class_name)

      updated_count = case_class.where(business_process_current_step: from_step_name)
                                 .update_all(business_process_current_step: to_step_name)

      Rails.logger.info "Updated #{updated_count} #{case_class_name} record(s) from '#{from_step_name}' to '#{to_step_name}'"
    end
  end
end
