# frozen_string_literal: true

require_relative "strata_task_helpers"

namespace :strata do
  namespace :events do
    extend StrataTaskHelpers

    desc "Publish a specified Strata event"
    task :publish_event, [ :event_name ] => [ :environment ] do |t, args|
      event_name = fetch_required_args!(args, :event_name).first

      Strata::EventManager.publish(event_name)

      Rails.logger.info "Event '#{event_name}' emitted successfully"
    end

    desc "Publish a specified Strata event for a given case with a given ID"
    task :publish_case_event, [ :event_name, :case_class, :case_id ] => [ :environment ] do |t, args|
      event_name, case_class, case_id = *fetch_required_args!(args, :event_name, :case_class, :case_id)
      constantized_case_class = case_class.constantize

      kase = constantized_case_class.find(case_id)
      Strata::EventManager.publish(event_name, { case_id: kase.id })

      Rails.logger.info "Event '#{event_name}' emitted for '#{case_class}' with ID '#{case_id}'"
    end

    desc "Dispatch committed events and retry due deliveries"
    task sweep: :environment do
      result = Strata::Events::Sweeper.call
      Rails.logger.info "Event sweep processed #{result.events} events and #{result.deliveries} deliveries"
    end

    desc "Prune terminal event history older than the given number of days"
    task :prune, [ :days ] => [ :environment ] do |_task, args|
      dry_run = ActiveModel::Type::Boolean.new.cast(ENV.fetch("DRY_RUN", false))
      result = Strata::Events::Pruner.call(older_than_days: args[:days], dry_run: dry_run)
      action = dry_run ? "would prune" : "pruned"
      Rails.logger.info(
        "Event retention #{action} #{result.events} events and #{result.deliveries} deliveries " \
        "older than #{result.cutoff.iso8601}"
      )
    end
  end
end
