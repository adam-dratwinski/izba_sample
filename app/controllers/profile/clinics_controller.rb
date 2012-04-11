class Profile::ClinicsController < Profile::BaseController
  before_filter :get_departament

  def index
    authorize! :read, @departament
    @search = @departament.clinics.metasearch(params[:search])
    @clinics = @search.relation.page(params[:page]).per(15) 
    @clinic = Clinic.new
  end

  def new
    @clinic = @departament.clinics.build
    authorize! :manage, @clinic
  end

  def create
    @clinic = @departament.clinics.build(params[:clinic])
    authorize! :manage, @clinic

    respond_to do |format| 
      if @clinic.save
        format.html { redirect_to profile_departament_clinics_path(@departament), :notice => I18n.t('clinics.notices.created') }
        format.js 
      else
        format.html { render :action => :new }
        format.js
      end
    end
  end

  def edit
    @clinic = @departament.clinics.find(params[:id])
    authorize! :manage, @clinic
  end

  def update
    @clinic = @departament.clinics.find(params[:id])
    authorize! :manage, @clinic

    if @clinic.update_attributes(params[:clinic])
      redirect_to profile_departament_clinics_path(@departament), :notice => I18n.t('clinics.notices.updated')
    else
      render :action => :edit
    end
  end

  def destroy
    @clinic = @departament.clinics.find(params[:id])
    authorize! :manage, @clinic
    @clinic.destroy

    respond_to do |format|
      format.html { redirect_to profile_departament_clinics_path(@departament), :notice => I18n.t('departaments.notices.destroyed') }
      format.js 
    end
  end

  private

  def get_departament
    @departament ||= Departament.find(params[:departament_id]) 
  end
end
