class ProvidersController < ApplicationController
  before_action :set_provider, only:  [:show, :edit, :update, :destroy]

  # GET /providers
  def index
    @title = t('view.providers.index_title')
    @searchable = true
    @providers = Provider.order(name: :asc).search(params[:q]).page(params[:page])
  end

  # GET /providers/1
  def show
    @title = t('view.providers.show_title')
    @transactions = @provider.transactions.preload(:movement).order(id: :desc).page(params[:page])
  end

  # GET /providers/new
  def new
    @title = t('view.providers.new_title')
    @provider = Provider.new
  end

  # GET /providers/1/edit
  def edit
    @title = t('view.providers.edit_title')
  end

  # POST /providers
  def create
    @title = t('view.providers.new_title')
    @provider = Provider.new(provider_params)

    respond_to do |format|
      if @provider.save
        format.html { redirect_to @provider, notice: t('view.providers.correctly_created') }
        format.json { render json: @provider }
      else
        format.html { render action: 'new' }
        format.json { render json: { errors: @provider.errors.full_messages.to_sentence } }
      end
    end
  end

  # PUT /providers/1
  def update
    @title = t('view.providers.edit_title')

    respond_to do |format|
      if @provider.update(provider_params)
        format.html { redirect_to @provider, notice: t('view.providers.correctly_updated') }
      else
        format.html { render action: 'edit' }
      end
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to edit_provider_url(@provider), alert: t('view.providers.stale_object_error')
  end

  # DELETE /providers/1
  def destroy
    opts = if @provider.destroy
             { notice: t('view.providers.correctly_destroyed') }
           else

             { alert: t('view.providers.cannot_be_destroyed', name: @provider.name) }
           end

    redirect_to providers_url, opts
  end

  private

  def set_provider
    @provider = Provider.find(params[:id])
  end

  def provider_params
    params.require(:provider).permit(:name)
  end
end
