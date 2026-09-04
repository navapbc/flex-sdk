# frozen_string_literal: true

class PassportBusinessProcessesController < ApplicationController
  FLOW_STEPS = [
    {
      key: "submit_application",
      number: "01",
      kind: "Applicant task",
      title: "Submit application",
      description: "The applicant completes their passport application.",
      event: "PassportApplicationFormSubmitted"
    },
    {
      key: "verify_identity",
      number: "02",
      kind: "System process",
      title: "Verify identity",
      description: "The identity service verifies the applicant automatically.",
      event: "IdentityVerified"
    },
    {
      key: "review_passport_photo",
      number: "03",
      kind: "Staff task",
      title: "Review passport photo",
      description: "A passport specialist reviews and approves the photo.",
      event: "PassportPhotoApproved"
    },
    {
      key: "end",
      number: "04",
      kind: "Outcome",
      title: "Passport approved",
      description: "The workflow is complete and the passport case is closed.",
      event: nil
    }
  ].freeze

  before_action :load_run, only: [ :show, :advance ]

  def show
    @flow_steps = FLOW_STEPS
    @events = events_for_run
    @photo_task = @passport_case&.tasks&.find { |task| task.is_a?(PassportPhotoTask) }
  end

  def start
    application_form = PassportApplicationForm.create!
    session[:passport_business_process_form_id] = application_form.id

    redirect_to passport_business_process_path,
      notice: "A new passport application entered the workflow."
  end

  def advance
    unless @application_form && @passport_case
      redirect_to passport_business_process_path,
        alert: "Start a workflow run before advancing it."
      return
    end

    case params[:transition]
    when "submit_application"
      submit_application
    when "approve_photo"
      approve_photo
    else
      redirect_to passport_business_process_path,
        alert: "That workflow action is not available."
    end
  end

  private

  def load_run
    form_id = session[:passport_business_process_form_id]
    @application_form = PassportApplicationForm.find_by(id: form_id) if form_id
    session.delete(:passport_business_process_form_id) if form_id && !@application_form
    @passport_case = PassportCase.find_by(application_form_id: @application_form&.id)
  end

  def submit_application
    unless current_step == "submit_application"
      redirect_to passport_business_process_path,
        alert: "The application has already moved beyond submission."
      return
    end

    @application_form.update!(
      name_first: "Avery",
      name_last: "Rivera",
      date_of_birth: Date.new(1992, 4, 18)
    )
    @application_form.submit_application

    redirect_to passport_business_process_path,
      notice: "Application submitted. Identity verification completed automatically."
  end

  def approve_photo
    unless current_step == "review_passport_photo"
      redirect_to passport_business_process_path,
        alert: "Photo approval is only available during staff review."
      return
    end

    Strata::EventManager.publish("PassportPhotoApproved", case_id: @passport_case.id)

    redirect_to passport_business_process_path,
      notice: "Photo approved. The passport case is now complete."
  end

  def current_step
    @passport_case&.business_process_current_step
  end

  def events_for_run
    return Strata::Event.none unless @application_form

    Strata::Event
      .includes(:deliveries)
      .where(
        "payload ->> 'application_form_id' = :form_id OR payload ->> 'case_id' = :case_id",
        form_id: @application_form.id.to_s,
        case_id: @passport_case&.id.to_s
      )
      .order(:occurred_at, :id)
  end
end
