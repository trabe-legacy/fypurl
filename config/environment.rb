RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

  config.frameworks -= [ :active_resource]
  config.active_record.default_timezone = :utc
  
  config.action_controller.session = {
    :session_key => '_fypurl_session',
    :secret      => '86ae24cb8f4d06f10796570e77faf2dc356d883ab71a8734825da36ba08b4bc6222498b68609be8e2bc0b5cff5eda1e1c0f448c38debdd964f63435c1d545538'
  }

  config.active_record.observers = :user_observer  
end


module ActionView::Helpers::DateHelper
  def time_ago_in_words(from_time, include_seconds = false)
   distance_of_time_in_words(from_time, Time.now.utc, include_seconds)
  end
end
