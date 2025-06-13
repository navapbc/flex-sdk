class PassportApplicationFormsController < ApplicationController
  def index
    @passport_application_forms = PassportApplicationForm.all
  end

  def new
    @passport_application_form = PassportApplicationForm.new
  end

  def create
    @passport_application_form = PassportApplicationForm.new(passport_application_form_params)

    if @passport_application_form.save
      redirect_to @passport_application_form, notice: 'Passport application was successfully created.'
    else
      render :new
    end
  end

  def show
    @passport_application_form = PassportApplicationForm.find(params[:id])
  end

  private

  def passport_application_form_params
    params.require(:passport_application_form).permit(:name_first, :name_middle, :name_last, :date_of_birth, supporting_documents_files: [])
  end
end
