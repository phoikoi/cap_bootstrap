Capistrano::Configuration.instance(:must_exist).load do
  namespace :ssl do
    desc "Setup nginx ssl configuration"
    task :copy, roles: :web do
      upload "#{certificate_location}", "/tmp/server.crt"
      upload "#{certificate_key_location}", "/tmp/server.key"
      run "#{sudo} mkdir -p /etc/nginx/ssl"
      run "#{sudo} mv /tmp/server.crt /etc/nginx/ssl/server.crt"
      run "#{sudo} mv /tmp/server.key /etc/nginx/ssl/server.key"
    end
    if :ssl then
      before "nginx:setup", "ssl:copy"
    end
  end
end
