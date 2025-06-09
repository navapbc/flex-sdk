namespace :flex do
  namespace :events do
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

    desc "Publish a specified Flex event"
    task :publish_event, [ :event_name ] => [ :environment ] do |t, args|
      event_name = fetch_required_args!(args, :event_name).first

      Flex::EventManager.publish(event_name)

      Rails.logger.info "Event '#{event_name}' emitted successfully"
    end

    desc "Publish a specified Flex event for a given case with a given ID"
    task :publish_case_event, [ :event_name, :case_class, :case_id ] => [ :environment ] do |t, args|
      event_name, case_class, case_id = *fetch_required_args!(args, :event_name, :case_class, :case_id)
      constantized_case_class = constantize_case_class(case_class)

      kase = constantized_case_class.find(case_id)
      Flex::EventManager.publish(event_name, { kase: kase })

      Rails.logger.info "Event '#{event_name}' emitted for '#{case_class}' with ID '#{case_id}'"
    end
  end
end
