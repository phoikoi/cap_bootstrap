Capistrano::Configuration.instance(:must_exist).load do
  set_default :ruby_version, "2.0.0-p247"
  set_default :rbenv_bootstrap, "bootstrap-ubuntu-12-04"

  namespace :rbenv do
    desc "Install rbenv, Ruby, and the Bundler gem"
    task :install, roles: :app do
      run "#{sudo} apt-get -y install curl git-core"
      run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"
      bashrc = <<-BASHRC
  export RBENV_ROOT="${HOME}/.rbenv"
  if [ -d "${RBENV_ROOT}" ]; then
    export PATH="${RBENV_ROOT}/bin:${PATH}"
    eval "$(rbenv init -)"
  fi
  BASHRC
      put bashrc, "/tmp/rbenvrc"
      run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
      run "mv ~/.bashrc.tmp ~/.bashrc"
      run "#{sudo} apt-get -y install build-essential tklib zlib1g-dev libssl-dev libreadline-gplv2-dev libxml2 libxml2-dev libxslt1-dev"
      run "rbenv install #{ruby_version}"
      run "rbenv global #{ruby_version}"
      run "gem install bundler --no-ri --no-rdoc"
      run "rbenv rehash"
    end
    after "deploy:install", "rbenv:install"
  end
end
