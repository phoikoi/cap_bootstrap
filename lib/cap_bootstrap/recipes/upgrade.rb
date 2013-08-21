Capistrano::Configuration.instance(:must_exist).load do
  namespace :upgrade do
    desc "Install latest stable release of nginx"
    task :all, roles: :web do
      run "export DEBIAN_FRONTEND=noninteractive"
      run "#{sudo} apt-get update -qq --force-yes"
      run "#{sudo} apt-get upgrade -qq --force-yes"
    end
    after "deploy:install", "upgrade:all"
  end
end
