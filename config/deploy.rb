set :application, 'abaco'
set :user, 'deployer'
set :repo_url, 'https://github.com/cetem/abaco.git'

set :scm, :git
set :deploy_to, '/var/rails/abaco'
set :deploy_via, :remote_cache

set :format, :pretty
set :log_level, :info

set :linked_files, %w{config/app_config.yml config/secrets.yml}
set :linked_dirs, %w{log private certs}

set :keep_releases, 5

namespace :deploy do
  after :finished, 'deploy:cleanup'
  after :finished, :restart

  desc 'Restart application'
  task :restart do
    on roles(:app) do
      execute '/etc/init.d/unicorn', 'upgrade'
    end
  end

  desc 'Clear the temps'
  task 'deploy:cleanup' do
    on roles(:all) do
      within release_path do
        execute :rake, 'tmp:clear'
      end
    end
  end
end
