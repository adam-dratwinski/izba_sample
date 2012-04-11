class ClinicsController < ApplicationController
  before_filter :set_city, :set_state

  def index
    @search_clinic = search_clinics
    @context_path = set_context_path

    @clinics = clinics @search_clinic

    respond_to do |format|
      format.html
      format.json 
      format.js { render :search }
    end
  end

  def show
    @clinic = Clinic.find(params[:id])
    @search_clinic = SearchClinic.new
    @context_path = set_context_path
  end

  def contact
    @clinic = Clinic.find(params[:id])
    @search_clinic = SearchClinic.new
    @context_path = set_context_path
  end

  def others
    @clinic = Clinic.find(params[:id])
    @clinics = @clinic.departament.clinics.where("id <> ?", @clinic.id)
    @search_clinic = SearchClinic.new
    @context_path = set_context_path
  end

  private

  def search_clinics
    if params[:id]
      search = SearchClinic.where("cached_slug = ? OR name = ?", params[:id], params[:id]).first || SearchClinic.create(:name => params[:id])

      SearchClinic.new(search.attributes)
    else 
      SearchClinic.new(:name => "")
    end
  end

  def clinics search_clinic
    search_options = {
      :star => true,
      :include => [:offices_with_specialisations, :departament, :city],
      :per_page => 20, :page => params[:page],
    }

    unless params[:l] == "poland"
      lat = session["coords"][0].to_f
      lng = session["coords"][1].to_f
      search_options.merge! :geo => [(lat / 180.0) * Math::PI, (lng / 180.0) * Math::PI]
    end

    if params[:sb] != "relevance" && lat && lng
      order = "@geodist ASC, @relevance DESC"
    else
      order = "@relevance DESC"
    end

    if params[:city_id]
      search_options.merge! :with => { :city_id => @city.id }
    end

    if params[:state_id]
      search_options.merge! :with => { :state_id => @state.id }
    end

    search_options.merge! :order => order

    Clinic.search search_clinic.name, search_options
  end

  def set_state
    if params[:state_id]
      @state = State.find(params[:state_id]) 
    elsif @city
      @state = @city.state
    end
  end

  def set_city
    @city = City.find(params[:city_id]) if params[:city_id]
  end

  def set_context_path
    if @city && ! @search_clinic.name.blank?
      search_city_clinic_path(@city, @search_clinic.name)
    elsif @city
      city_clinics_path(@city)
    elsif @state && ! @search_clinic.name.blank?
      search_state_clinic_path(@state, @search_clinic.name)
    elsif @state
      state_clinics_path(@state)
    elsif ! @search_clinic.name.blank?
      search_clinic_path(@search_clinic.name)
    elsif clinics_path != request.path
      clinics_states_path
    else
      clinics_path
    end
  end
end
