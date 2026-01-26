# frozen_string_literal: true

class PaidLeaveApplicationFormsController < ApplicationController
  include Strata::Flows::ApplicationFormController

  before_action :set_new_form, only: [ :new, :create ]
  before_action :set_form, except: [ :new, :create, :index ]
  flow PaidLeaveFlow

  def index
    @paid_leave_application_forms = PaidLeaveApplicationForm.all
  end

  def new
  end

  def show
  end

  def create
    if @paid_leave_application_form.save
      redirect_to @paid_leave_application_form
    else
      flash.now[:errors] = @paid_leave_application_form.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  def review
  end

  def submit
    if @paid_leave_application_form.submit_application
      redirect_to paid_leave_application_form_path(@paid_leave_application_form)
    elsif @paid_leave_application_form.errors.full_messages
      flash.now[:errors] = @paid_leave_application_form.errors.full_messages
      render :review, status: :unprocessable_entity
    else
      raise StandardError.new("The leave application could not be submitted.")
    end
  end

  def flow_record
    @paid_leave_application_form
  end

  private

  def set_new_form
    @paid_leave_application_form = PaidLeaveApplicationForm.new
  end

  def set_form
    @paid_leave_application_form = PaidLeaveApplicationForm.find(params[:id])
  end
end
