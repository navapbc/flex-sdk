module Flex
  class CasesController < ApplicationController
    abstract_class!
    layout "application"
    helper_method :model_class

    def index
      @cases = model_class.order(created_at: :desc)
                          .all
    end

    def closed
      @cases = model_class.where(status: "closed")
                          .order(created_at: :desc)
      render :index
    end

    def new
    end

    def create
    end

    def show
      @case = model_class.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:error] = "Case not found"
      redirect_to cases_path
    end

    def edit
    end

    def update
    end

    def model_class
      controller_path.classify.constantize
    end
  end
end
