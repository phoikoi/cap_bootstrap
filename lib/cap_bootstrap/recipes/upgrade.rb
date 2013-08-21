Capistrano::Configuration.instance(:must_exist).load do
  namespace :upgrade do
    desc "Upgrade system"
    task :all, roles: :web do
      run "#{sudo} apt-get update -qq --force-yes"
      run "#{sudo} apt-get upgrade -qq --force-yes", :env => { 'DEBIAN_FRONTEND' => 'noninteractive' }
    end
    after "deploy:install", "upgrade:all"
  end
end
