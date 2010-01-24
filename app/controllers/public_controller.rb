class PublicController < ApplicationController

  def index
    redirect_to :controller => 'user', :action => 'index' if logged_in?
  end

  def user_unknown
  end

  def no_url
  end

  def legal_info
  end
end
