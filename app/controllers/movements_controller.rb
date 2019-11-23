class MovementsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_movement, only: [:show, :edit, :update, :destroy, :revoke]

  layout ->(c) { c.request.xhr? ? false : 'application' }

  check_authorization
  load_and_authorize_resource

  # GET /movements
  # GET /movements.json
  def index
    @title = t('view.movements.index_title')
    @movements = Movement.filtered_by(params[:filter]).
      order(id: :desc, bought_at: :desc).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @movements }
    end
  end

  # GET /movements/1
  # GET /movements/1.json
  def show
    @title = t('view.movements.show_title')

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @movement }
    end
  end

  # GET /movements/new
  # GET /movements/new.json
  def new
    @title = t('view.movements.new_title')
    @movement = Movement.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @movement }
    end
  end

  # GET /movements/1/edit
  def edit
    @title = t('view.movements.edit_title')
  end

  # POST /movements
  # POST /movements.json
  def create
    @title = t('view.movements.new_title')
    @movement = Movement.new(movement_params)
    @movement.user_id = current_user.id

    respond_to do |format|
      if @movement.save
        format.html { redirect_to @movement, notice: t('view.movements.correctly_created') }
        format.json { render json: @movement, status: :created, location: @movement }
      else
        format.html { render action: 'new' }
        format.json { render json: @movement.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /movements/1
  # PUT /movements/1.json
  def update
    @title = t('view.movements.edit_title')

    respond_to do |format|
      if @movement.update_attributes(movement_params)
        format.html { redirect_to @movement, notice: t('view.movements.correctly_updated') }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @movement.errors, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to edit_movement_url(@movement), alert: t('view.movements.stale_object_error')
  end

  def revoke
    @movement.revoke!

    redirect_to movements_url
  end

  # GET /PRINT_HUB_APP/users/autocomplete_for_user_name
  # def autocomplete_for_operator
  #   @operators = RemoteOperator.get(:autocomplete_for_user_name, q: params[:q])

  #   respond_to do |format|
  #     format.json { render json: @operators }
  #   end
  # end

  def autocomplete_for_association
    @association = case params[:type]
                   when 'Provider', 'Operator', 'Box'
                     params[:type].constantize.search(params[:q]).limit(10)
                   else
                     []
                   end

    respond_to do |format|
      format.json { render json: @association }
    end
  end


  # GET /movements/show_all_pay_pending_shifts
  def show_all_pay_pending_shifts
    @title = t('view.movements.shifts.title')
    @operators_shifts = []

    if params[:interval]
      interval = parameterize_to_datetime_format(params[:interval])
      start, finish = [interval[:from], interval[:to]]

      if start.present? && finish.present?
        @operators_shifts = Movement.operators_pay_pending_shifts_between(
          start.beginning_of_day, finish.end_of_day
        )
      end
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # PUT /movements/pay_shifts
  def pay_shifts
    interval = parameterize_to_datetime_format(params) # params has direct from and to keys
    start, finish = [interval[:from], interval[:to]].sort
    @operator_id = params[:operator_id]
    @paid = Movement.pay_operator_shifts_and_upfronts(
      charged_by:     current_user.to_s,
      operator_id:    @operator_id,
      start:          start.beginning_of_day,
      finish:         finish.end_of_day,
      amount:         params[:total_to_pay].to_f,
      upfronts:       params[:upfronts].to_f,
      user_id:        current_user.id,
      with_incentive: params[:with_incentive].to_s.to_bool
    )

    @operator = RemoteOperator.find(@operator_id) if @paid

    respond_to { |f| f.js }
  end

  private

  def set_movement
    @movement = Movement.find(params[:id])
  end

  def movement_params
    params.require(:movement).permit(
      :amount, :comment, :kind, :lock_version, :with_incentive,
      :user_id, :bill, :bought_at, :with_receipt,
      :file, :file_cache, :charged_by,
      :from_account_type, :from_account_autocomplete, :from_account_id,
      :to_account_type, :to_account_autocomplete, :to_account_id
    )
  end
end
