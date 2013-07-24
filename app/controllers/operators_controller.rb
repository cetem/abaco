class OperatorsController < ApplicationController
  def index
    @operators = Operator.get(:current_workers)

    respond_to do |format|
      format.html
      format.json { render json: @operators }
    end
  end

  def show
    @operator = Operator.find(params[:id])
    offset = params[:page] ? (params[:page].to_i - 1) * 10 : 0

    @shifts = OperatorShifts.get(:json_paginate, 
      user_id: @operator.id, offset: offset, limit: 10
    )
    @paginate_size = @shifts.size

    @movements = Outflow.for_operator(@operator.id).order(id: :desc).paginate(
      page: params[:movements_page]
    )

    respond_to do |format|
      format.html
    end
  end
end
