class PassportApplicationFormsController < ApplicationController
  def index
    @passport_application_forms = PassportApplicationForm.all
  end

  def show
    @passport_application_form = PassportApplicationForm.find(params[:id])
  end
end
