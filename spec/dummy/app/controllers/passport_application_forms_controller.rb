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
end
