module Flex
  class CasesController < ApplicationController
    layout "application"

    def index
      @cases = model_class.order(created_at: :desc)
                          .all
    end

    def new
    end

    def create
    end

    def show
      @case = Case.find(params[:id])
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
