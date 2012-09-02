class SettingsController < ApplicationController
  
  # GET /settings
  # GET /settings.json
  def index
    @title = t('view.settings.index_title')
    @settings = Setting.page(params[:page])

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @settings }
    end
  end

  # GET /settings/1
  # GET /settings/1.json
  def show
    @title = t('view.settings.show_title')
    @setting = Setting.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @setting }
    end
  end

  # GET /settings/new
  # GET /settings/new.json
  def new
    @title = t('view.settings.new_title')
    @setting = Setting.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @setting }
    end
  end

  # GET /settings/1/edit
  def edit
    @title = t('view.settings.new_title')
    @setting = Setting.find(params[:id])
  end

  # POST /settings
  # POST /settings.json
  def create
    @title = t('view.settings.new_title')
    @setting = Setting.new(params[:setting])

    respond_to do |format|
      if @setting.save
        format.html { redirect_to @setting, notice: t('view.settings.correctly_created') }
        format.json { render json: @setting, status: :created, location: @setting }
      else
        format.html { render action: 'new' }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /settings/1
  # PUT /settings/1.json
  def update
    @title = t('view.settings.edit_title')
    @setting = Setting.find(params[:id])

    respond_to do |format|
      if @setting.update_attributes(params[:setting])
        format.html { redirect_to @setting, notice: t('view.settings.correctly_updated') }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @setting.errors, status: :unprocessable_entity }
      end
    end
  rescue ActiveRecord::StaleObjectError
    redirect_to edit_setting_url(@setting), alert: t('view.settings.stale_object_error')
  end
end
