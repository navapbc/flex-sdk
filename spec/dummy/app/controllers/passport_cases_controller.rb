class PassportCasesController < Flex::StaffController
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
    @case = PassportCase.find(params[:id])
  end

  def edit
  end

  def update
  end

  def model_class
    controller_path.classify.constantize
  end
end
