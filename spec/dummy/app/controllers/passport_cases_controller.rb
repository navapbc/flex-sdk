class PassportCasesController < StaffController
  before_action :set_case, only: %i[ show application_details documents history notes tasks ]

  def index
    @cases = PassportCase.order(created_at: :desc)
                         .all
  end

  def closed
    @cases = PassportCase.where(status: "closed")
                         .order(created_at: :desc)
    render :index
  end

  def new
  end

  def create
  end

  def show
  end

  def application_details
  end

  def tasks
  end

  def documents
  end

  def history
  end

  def notes
  end

  def edit
  end

  def update
  end

  def model_class
    controller_path.classify.constantize
  end

  private

    def set_case
      @case = PassportCase.find(params[:id])
    end
end
