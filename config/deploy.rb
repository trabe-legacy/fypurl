set :application, "fypurl"

role :web, "fypurl.com"
role :app, "fypurl.com"
role :db,  "fypurl.com", :primary => true

set :deploy_to, "/home/trabe/fypurl.com"
set :deploy_via, :copy
set :keep_releases, 3

set :user, "trabe"
set :use_sudo, false
set :checkout, "export"

set :repository, "git://github.com/davidbarral/fypurl.git"
set :scm, "git"
set :scm_verbose, true
set :branch, "master"
set :git_shallow_clone, 1

namespace :passenger do 
  desc "Restart Passenger"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end    
end

namespace :deploy do
  task :restart do
    passenger.restart
  end 
end

