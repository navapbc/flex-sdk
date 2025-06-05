namespace :flex do
  desc "Emit a specified Flex event for a given case with a given ID"
  task :emit_event, [ :event_name, :case_class, :case_id ] => [ :environment ] do |t, args|
    event_name = args[:event_name]
    case_id = args[:case_id]
    case_class = args[:case_class]

    if event_name.blank? || case_class.blank? || case_id.blank?
      raise "Error: event_name, case_class, and case_id are required."
    end

    kase = case_class.constantize.find(case_id)
    Flex::EventManager.publish(event_name, { kase: kase })
    puts "Event '#{event_name}' emitted for #{case_class} with ID '#{case_id}'"
  end
end
