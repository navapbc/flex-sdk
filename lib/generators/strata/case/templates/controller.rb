class <%= class_name.pluralize %>Controller < StaffController
  before_action :set_<%= file_name %>, only: %i[ show tasks documents notes ]
  before_action :set_application_form, only: %i[ show tasks documents notes ]

  def index
    @<%= file_name.pluralize %> = <%= class_name %>.all
  end

  def closed
    @<%= file_name.pluralize %> = <%= class_name %>.where(status: 'closed')
    render :index
  end

  def show
  end

  def tasks
    @tasks = @<%= file_name %>.tasks
  end

  def documents
  end

  def notes
  end

  private

  def set_<%= file_name %>
    @<%= file_name %> = <%= class_name %>.find(params[:id])
  end

  def set_application_form
    @application_form = @<%= file_name %>.application_form if @<%= file_name %>.present?
  end
end
