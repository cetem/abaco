class OutflowsController < ApplicationController
  before_action :authenticate_user!

  layout ->(c) { c.request.xhr? ? false : 'application' }

  # GET /outflows
  # GET /outflows.json
  def index
    @title = t('view.outflows.index_title')
    @outflows = Outflow.filtered_by(params[:filter]).order(bought_at: :desc).page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @outflows }
    end
  end

  # GET /outflows/1
  # GET /outflows/1.json
  def show
    @title = t('view.outflows.show_title')
    @outflow = Outflow.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @outflow }
    end
  end

  # GET /outflows/new
  # GET /outflows/new.json
  def new
    @title = t('view.outflows.new_title')
    @outflow = Outflow.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @outflow }
    end
  end

  # GET /outflows/1/edit
  def edit
    @title = t('view.outflows.edit_title')
    @outflow = Outflow.find(params[:id])
  end

  # POST /outflows
  # POST /outflows.json
  def create
    @title = t('view.outflows.new_title')
    @outflow = Outflow.new(outflow_params)
    @outflow.user_id = current_user.id

    respond_to do |format|
      if @outflow.save
        format.html { redirect_to @outflow, notice: t('view.outflows.correctly_created') }
        format.json { render json: @outflow, status: :created, location: @outflow }
      else
        format.html { render action: 'new' }
        format.json { render json: @outflow.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /outflows/1
  # PUT /outflows/1.json
  def update
    @title = t('view.outflows.edit_title')
    @outflow = Outflow.find(params[:id])

    respond_to do |format|
      if @outflow.update_attributes(outflow_params)
        format.html { redirect_to @outflow, notice: t('view.outflows.correctly_updated') }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @outflow.errors, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to edit_outflow_url(@outflow), alert: t('view.outflows.stale_object_error')
  end

  # DELETE /outflows/1
  # DELETE /outflows/1.json
  def destroy
    @outflow = Outflow.find(params[:id])
    @outflow.destroy

    respond_to do |format|
      format.html { redirect_to outflows_url }
      format.json { head :ok }
    end
  end

  # GET /PRINT_HUB_APP/users/autocomplete_for_user_name
  def autocomplete_for_operator
    @operators = Operator.get(:autocomplete_for_user_name, q: params[:q])

    respond_to do |format|
      format.json { render json: @operators }
    end
  end

  # GET /outflows/show_pay_pending_shifts
  def show_pay_pending_shifts
    @title = t('view.outflows.shifts.title')

    if params[:interval]
      interval = params[:interval]
      values = parameterize_to_date_format(interval)
      from, to = values[:from], values[:to]
      operator_id, admin = interval[:operator_id], interval[:operator_admin]

      if operator_id.present? && from.present? && to.present?
        @operator_shifts = Outflow.operator_pay_pending_shifts_between(
          operator_id: operator_id,
          start: from,
          finish: to,
          admin: admin
        )

        @operator_current_credit = Outflow.credit_for_operator(operator_id)
      end
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /outflows/show_all_pay_pending_shifts
  def show_all_pay_pending_shifts
    @title = t('view.outflows.shifts.title')

    if params[:interval]
      interval = params[:interval]
      values = parameterize_to_date_format(interval)
      from, to = values[:from], values[:to]
      @operator_shifts = []
      operators = Operator.get(:current_workers)

      if from.present? && to.present?
        operators.each do |o|
          detail = Outflow.operator_pay_pending_shifts_between(
            operator_id: o['id'],
            start: from,
            finish: to,
            admin: o['admin']
          )

          @operator_shifts << {
            detail: detail, credit: Outflow.credit_for_operator(o['id']),
            id: o['id'], label: o['label']
          } if detail
        end
      end
    end

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # PUT /outflows/pay_shifts
  def pay_shifts
    @paid = Outflow.pay_operator_shifts_and_upfronts(
      operator_id: params[:id],
      start: params[:from],
      finish: params[:to],
      amount: params[:total_to_pay],
      upfronts: params[:upfronts].to_f,
      user_id: current_user.id,
      with_incentive: params[:with_incentive].to_s.to_bool
    )

    if @paid
      if request.xhr?
        @operator = Operator.find(params[:id])
        respond_to { |f| f.js }
      else
        redirect_to outflows_path, notice: t('view.outflows.shifts.paid_notice')
      end
    else
      redirect_to :back, notice: t('view.outflows.shifts.can_not_be_paid')
    end
  end

  private

    def outflow_params
      params.require(:outflow).permit(
        :amount, :comment, :kind, :lock_version, :operator_id, :with_incentive,
        :auto_operator_name, :user_id, :bill, :provider, :bought_at
      )
    end
end
