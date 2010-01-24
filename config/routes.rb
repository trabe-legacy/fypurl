ActionController::Routing::Routes.draw do |map|

  map.connect 'home', :controller => 'public', :action => 'index'
  map.connect 'unknown_user', :controller => 'public', :action => 'user_unknown'
  map.connect 'user_has_no_url', :controller => 'public', :action => 'no_url'
  map.connect 'legal_info', :controller => 'public', :action => 'legal_info'

  map.connect 'login', :controller => 'user', :action => 'login'
  map.connect 'signup', :controller => 'user', :action => 'signup'
  map.connect 'activate_account/:activation_code', :controller => 'user', :action => 'activate'
  map.connect 'logout', :controller => 'user', :action => 'logout'
  map.connect 'admin', :controller => 'user', :action => 'index'
  map.connect 'forgotten_password', :controller => 'user', :action => 'forgotten_password'
  map.connect 'change_password', :controller => 'user', :action => 'change_password'

  map.connect 'fyp', :controller => 'user', :action => 'fyp'
  map.connect 'unfyp', :controller => 'user', :action => 'unfyp'

  map.connect 'fyp_express', :controller => 'user', :action => 'fyp_express'
  map.connect 'unfyp_express', :controller => 'user', :action => 'unfyp_express'
  map.connect 'login_express', :controller => 'user', :action => 'login_express'

  map.user ':user', :controller => 'user', :action => 'go_to_url'

  # Install the default route as the lowest priority.
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action/:id'

  map.connect '', :controller => 'public', :action => 'index'
end
