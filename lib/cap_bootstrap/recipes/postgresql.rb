Capistrano::Configuration.instance(:must_exist).load do
  set_default(:postgresql_host, "localhost")
  set_default(:postgresql_user) { application }
  set_default(:postgresql_password) { Capistrano::CLI.password_prompt "PostgreSQL Password: " }
  set_default(:postgresql_database) { "#{application}_production" }

  namespace :postgresql do
    desc "Install the latest stable release of PostgreSQL."
    task :install, roles: :db, only: {primary: true} do
      run "#{sudo} wget -q -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -"
      run "#{sudo} echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /tmp/postgresql.list"
      run "#{sudo} mv /tmp/postgresql.list /etc/apt/sources.list.d/postgresql.list"
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install postgresql postgresql-contrib libpq-dev"
    end
    after "deploy:install", "postgresql:install"

    desc "Create a database for this application."
    task :create_database, roles: :db, only: {primary: true} do
      run %Q{#{sudo} -u postgres psql -c "create role #{postgresql_user} login password '#{postgresql_password}';"}
      run %Q{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
    end
    after "deploy:setup", "postgresql:create_database"

    desc "Generate the database.yml configuration file."
    task :setup, roles: :app do
      run "mkdir -p #{shared_path}/config"
      template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
    end
    after "deploy:setup", "postgresql:setup"

    desc "Symlink the database.yml file into latest release"
    task :symlink, roles: :app do
      run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    end
    after "deploy:finalize_update", "postgresql:symlink"
  end
end
