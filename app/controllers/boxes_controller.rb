class BoxesController < ApplicationController
  before_action :set_box, only:  [:show, :edit, :update, :destroy]

  # GET /boxes
  def index
    @title = t('view.boxes.index_title')
    @searchable = true
    @boxes = Box.order(name: :asc).search(params[:q]).page(params[:page])
  end

  # GET /boxes/1
  def show
    @title = t('view.boxes.show_title')
    @transactions = @box.transactions.preload(:movement).order(id: :desc).page(params[:page])
  end

  # GET /boxes/new
  def new
    @title = t('view.boxes.new_title')
    @box = Box.new
  end

  # GET /boxes/1/edit
  def edit
    @title = t('view.boxes.edit_title')
  end

  # POST /boxes
  def create
    @title = t('view.boxes.new_title')
    @box = Box.new(box_params)

    respond_to do |format|
      if @box.save
        format.html { redirect_to @box, notice: t('view.boxes.correctly_created') }
        format.json { render json: @box }
      else
        format.html { render action: 'new' }
        format.json { render json: { errors: @box.errors.full_messages.to_sentence } }
      end
    end
  end

  # PUT /boxes/1
  def update
    @title = t('view.boxes.edit_title')

    respond_to do |format|
      if @box.update(box_params)
        format.html { redirect_to @box, notice: t('view.boxes.correctly_updated') }
      else
        format.html { render action: 'edit' }
      end
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to edit_box_url(@box), alert: t('view.boxes.stale_object_error')
  end

  # DELETE /boxes/1
  def destroy
    opts = if @box.destroy
             { notice: t('view.boxes.correctly_destroyed') }
           else

             { alert: t('view.boxes.cannot_be_destroyed', name: @box.name) }
           end

    redirect_to boxes_url, opts
  end

  private

  def set_box
    @box = Box.find(params[:id])
  end

  def box_params
    params.require(:box).permit(:name, :default_cashbox)
  end
end
