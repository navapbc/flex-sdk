
  class ApplicationForm < ApplicationRecord
    self.abstract_class = true

    # Shared attributes
    attribute :status, :string
    attribute :applicant_id, :integer
    attribute :submitted_at, :datetime

    # Prevent updating submitted applications
    def update(*args, **kwargs)
      raise_status_error unless status_allows_updates?
      super(*args, **kwargs)
    end

    def update_attributes(*args)
      raise_status_error unless status_allows_updates?
      super
    end


    # Example valid statuses for an application
    STATUSES = %w[in_progress submitted in_review approved denied].freeze

    # Ensure status is always valid
    validates :status, inclusion: { in: STATUSES }

    # Save application as in-progress
    def save_in_progress
      self.status ||= "in_progress"
      save!
    end

    # Submit application and freeze further submissions
    def submit
      raise "Cannot submit an already submitted application" if status != "in_progress"
      self.status = "in_review"
      save!
    end

    private

    def status_allows_updates?
      status == "in_progress"
    end

    def raise_status_error
      raise ActiveRecord::RecordInvalid.new(self), "Updates are not allow on submitted applications"
    end
  end
