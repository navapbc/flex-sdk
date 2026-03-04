# frozen_string_literal: true

class PassportApplicationFormsController < ApplicationController
  def index
    @passport_application_forms = PassportApplicationForm.all
  end

  def new
    @passport_application_form = PassportApplicationForm.new
  end

  def show
    @passport_application_form = PassportApplicationForm.find(params[:id])
  end

  def edit
    @passport_application_form = PassportApplicationForm.find(params[:id])
  end

  def update
    @passport_application_form = PassportApplicationForm.find(params[:id])

    if @passport_application_form.update(passport_application_form_params)
      if params[:commit] == "Submit"
        if @passport_application_form.submit_application
          redirect_to @passport_application_form, notice: "Passport application form was successfully submitted."
          return
        else
          flash.now[:errors] = @passport_application_form.errors.full_messages
          render :edit, status: :unprocessable_entity
          return
        end
      end

      redirect_to @passport_application_form, notice: "Passport application form was successfully updated."
    else
      flash.now[:errors] = @passport_application_form.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def create
    @passport_application_form = PassportApplicationForm.new(passport_application_form_params)

    if @passport_application_form.save
      if params[:commit] == "Submit"
        if @passport_application_form.submit_application
          redirect_to @passport_application_form, notice: "Passport application form was successfully submitted."
          return
        else
          flash.now[:errors] = @passport_application_form.errors.full_messages
          render :new, status: :unprocessable_entity
          return
        end
      end

      redirect_to @passport_application_form, notice: "Passport application form was successfully saved."
    else
      flash.now[:errors] = @passport_application_form.errors.full_messages
      render :new, status: :unprocessable_entity
    end
  end

  private

  def passport_application_form_params
    params.require(:passport_application_form).permit(
      :name_first,
      :name_middle,
      :name_last,
      :name_suffix,
      date_of_birth: [ :month, :day, :year ]
    )
  end
end
