# frozen_string_literal: true

class LeaveRequestApplicationFormsController < ApplicationController
  def index
    @leave_request_application_forms = LeaveRequestApplicationForm.all
  end

  def new
    @leave_request_application_form = LeaveRequestApplicationForm.new
  end

  def show
    @leave_request_application_form = LeaveRequestApplicationForm.find(params[:id])
  end

  def edit
    @leave_request_application_form = LeaveRequestApplicationForm.find(params[:id])
  end

  def update
    @leave_request_application_form = LeaveRequestApplicationForm.find(params[:id])

    if @leave_request_application_form.update(leave_request_application_form_params)
      if params[:commit] == "Submit"
        if @leave_request_application_form.submit_application
          redirect_to @leave_request_application_form, notice: "Leave request was successfully submitted."
          return
        else
          flash.now[:errors] = @leave_request_application_form.errors.full_messages
          render :edit, status: :unprocessable_content
          return
        end
      end

      redirect_to @leave_request_application_form, notice: "Leave request was successfully updated."
    else
      flash.now[:errors] = @leave_request_application_form.errors.full_messages
      render :edit, status: :unprocessable_content
    end
  end

  def create
    @leave_request_application_form = LeaveRequestApplicationForm.new(leave_request_application_form_params)

    if @leave_request_application_form.save
      if params[:commit] == "Submit"
        if @leave_request_application_form.submit_application
          redirect_to @leave_request_application_form, notice: "Leave request was successfully submitted."
          return
        else
          flash.now[:errors] = @leave_request_application_form.errors.full_messages
          render :new, status: :unprocessable_content
          return
        end
      end

      redirect_to @leave_request_application_form, notice: "Leave request was successfully saved."
    else
      flash.now[:errors] = @leave_request_application_form.errors.full_messages
      render :new, status: :unprocessable_content
    end
  end

  private

  def leave_request_application_form_params
    params.require(:leave_request_application_form).permit(
      :first_name,
      :last_name,
      :street_address,
      :zip_code,
      date_of_birth: [ :month, :day, :year ]
    )
  end
end
