# frozen_string_literal: true

# Shared helper methods for Strata rake tasks
module StrataTaskHelpers
  def fetch_required_args!(args, *required_keys)
    missing = required_keys.select { |k| args[k].blank? }
    if missing.any?
      verb = missing.size == 1 ? "is" : "are"
      raise "Error: #{missing.to_sentence} #{verb} required"
    end

    required_keys.map { |k| args[k] }
  end

  def constantize_case_class(case_class)
    begin
      case_class.constantize
    rescue NameError
      raise "Error: case_class '#{case_class}' is not a valid constant."
    end
  end
end
