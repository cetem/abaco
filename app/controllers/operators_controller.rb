class OperatorsController < ApplicationController
  before_action :authorize_read, only: [:index, :show]
  before_action :authorize_write, except: [:index, :show]

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

    @shifts = OperatorShift.get(:json_paginate,
      user_id: @operator.id, offset: offset, limit: 10
    )

    @shifts = OperatorShift.convert_hash_in_open_struct(@shifts)

    @paginate_size = @shifts.size

    if can? :read, Outflow
      @movements = Outflow.for_operator(@operator.id).order(bought_at: :desc).paginate(
        page: params[:movements_page]
      )
    end
  end

  def new_shift
    @operator = Operator.find(params[:id])
    @operator_shift = OperatorShift.new(as_admin: @operator.admin)
  end

  def edit_shift
    @operator = Operator.find(params[:operator_id])
    @operator_shift = OperatorShifts.find(params[:id])
  end

  def create_shift
    @operator = Operator.find(params[:id])

    @operator_shift = OperatorShift.new(
      operator_shift_params.merge(user_id: @operator.id)
    )

    if @operator_shift.save
      redirect_to operator_path(@operator), notice: t('view.operators.shift_created')
    else
      render 'new_shift', notice: t('view.operators.shift_can_not_be_created')
    end
  end

  def update_shift
    @operator = Operator.find(params[:operator_id])

    @operator_shift = OperatorShifts.find(params[:id])
    @operator_shift.attributes.merge! operator_shift_params

    if @operator_shift.save
      redirect_to operator_path(@operator), notice: t('view.operators.shift_updated')
    else
      render 'edit_shift', notice: t('view.operators.shift_can_not_be_updated')
    end
  end

  private

  def operator_shift_params
    params.require(:operator_shift).permit(:start, :finish, :as_admin)
  end

  def authorize_read
    authorize! :read, Operator
  end

  def authorize_write
    authorize! :write, Operator
  end
end
