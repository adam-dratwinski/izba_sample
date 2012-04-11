class ApplicationController < ActionController::Base
  include ControllerAuthentication
  protect_from_forgery
  before_filter :set_user_location

  def set_user_location
    session[:coords] ||= session[:coords].presence || [request.location.latitude, request.location.longitude]
    session[:address] ||= session[:address].presence || request.location.city

    current_user.coords  = session[:coords]
    current_user.current_address = session[:address]
  end

  rescue_from CanCan::AccessDenied do |exception|
    exception.default_message = I18n.t('globals.access_denied')
    redirect_to root_url, :alert => exception.message
  end
end
