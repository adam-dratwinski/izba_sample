class Profile::BaseController < ApplicationController
  layout 'profile'

  before_filter :login_required
end
