Capistrano::Configuration.instance(:must_exist).load do
  namespace :nginx do
    desc "Install latest mainline release of nginx"
    task :install, roles: :web do
      run "#{sudo} add-apt-repository -y ppa:nginx/development"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install nginx"
    end
    after "deploy:install", "nginx:install"

    desc "Setup nginx ssl configuration"
    task :ssl, roles: :web do
      if `#{ssl}` == true
        upload "#{certificate_location}", "/tmp/server.crt"
        upload "#{certificate_key_location}", "/tmp/server.key"
        run "#{sudo} mkdir -p /etc/nginx/ssl"
        run "#{sudo} mv /tmp/server.crt /etc/nginx/ssl/server.crt"
        run "#{sudo} mv /tmp/server.key /etc/nginx/ssl/server.key"
      end
    end
    after "deploy:setup", "nginx:ssl"

    desc "Setup nginx configuration for this application"
    task :setup, roles: :web do
      template "nginx_unicorn.erb", "/tmp/nginx_conf"
      run "#{sudo} mv /tmp/nginx_conf /etc/nginx/sites-enabled/#{application}"
      run "#{sudo} rm -f /etc/nginx/sites-enabled/default"
      restart
    end
    after "deploy:setup", "nginx:setup"
  
    %w[start stop restart].each do |command|
      desc "#{command} nginx"
      task command, roles: :web do
        run "#{sudo} service nginx #{command}"
      end
    end
  end
end
