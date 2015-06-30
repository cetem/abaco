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

    @shifts = OperatorShifts.convert_hash_in_open_struct(@shifts)

    @paginate_size = @shifts.size

    @movements = Outflow.for_operator(@operator.id).order(bought_at: :desc).paginate(
      page: params[:movements_page]
    )
  end

  def new_shift
    @operator = Operator.find(params[:id])
    @operator_shift = OperatorShifts.new(as_admin: @operator.admin)
  end

  def create_shift
    @operator = Operator.find(params[:id])

    @operator_shift = OperatorShifts.new(
      operator_shift_params.merge(user_id: @operator.id)
    )

    if @operator_shift.save
      redirect_to operator_path(@operator), notice: t('view.operators.shift_created')
    else
      render 'new_shift', notice: t('view.operators.shift_can_not_be_created')
    end
  end

  private

  def operator_shift_params
    params.require(:operator_shifts).permit(:start, :finish, :as_admin)
  end
end
