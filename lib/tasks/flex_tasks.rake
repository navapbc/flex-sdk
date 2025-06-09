namespace :flex do
  namespace :events do
    desc "Publish a specified Flex event"
    task :publish_event, [ :event_name ] => [ :environment ] do |t, args|
      event_name = args[:event_name]

      if event_name.blank?
        raise "Error: event_name is required."
      end

      Flex::EventManager.publish(event_name)

      Rails.logger.info "Event '#{event_name}' emitted successfully"
    end

    desc "Publish a specified Flex event for a given case with a given ID"
    task :publish_case_event, [ :event_name, :case_class, :case_id ] => [ :environment ] do |t, args|
      event_name = args[:event_name]
      case_id = args[:case_id]
      case_class = args[:case_class]

      if event_name.blank? || case_class.blank? || case_id.blank?
        raise "Error: event_name, case_class, and case_id are required."
      end

      kase = case_class.constantize.find(case_id)
      Flex::EventManager.publish(event_name, { kase: kase })
      puts "Event '#{event_name}' emitted for '#{case_class}' with ID '#{case_id}'"
    end
  end
end
