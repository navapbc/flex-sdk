# frozen_string_literal: true

namespace :strata do
  namespace :cases do
    def fetch_required_args!(args, *required_keys)
      missing = required_keys.select { |k| args[k].blank? }
      if missing.any?
        verb = missing.size == 1 ? "is" : "are"
        raise "Error: #{missing.to_sentence} #{verb} required"
      end

      required_keys.map { |k| args[k] }
    end

    desc "Migrate Case#business_process_current_step from one step name to another"
    task :migrate_business_process_current_step, [ :from_step_name, :to_step_name ] => [ :environment ] do |t, args|
      from_step_name, to_step_name = *fetch_required_args!(args, :from_step_name, :to_step_name)

      case_classes = Strata::Case.descendants

      total_updated = 0

      case_classes.each do |case_class|
        updated_count = case_class.where(business_process_current_step: from_step_name)
                                   .update_all(business_process_current_step: to_step_name)
        total_updated += updated_count

        if updated_count > 0
          Rails.logger.info "Updated #{updated_count} #{case_class.name} record(s) from '#{from_step_name}' to '#{to_step_name}'"
        end
      end

      Rails.logger.info "Migration completed: #{total_updated} total case(s) updated from '#{from_step_name}' to '#{to_step_name}'"
    end
  end
end
