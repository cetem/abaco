class OutflowsController < ApplicationController
  before_filter :authenticate_user!
  
  # GET /outflows
  # GET /outflows.json
  def index
    @title = t('view.outflows.index_title')
    @outflows = Outflow.page(params[:page])

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
    @outflow = Outflow.new(params[:outflow])
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
      if @outflow.update_attributes(params[:outflow])
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
  
  def autocomplete_for_operator
    @operators = Operator.find(
      :all, from: '/users/autocomplete_for_user_name', params: { q: params[:q] }
    )
    
    respond_to do |format|
      format.json { render json: @operators }
    end
  end
end
