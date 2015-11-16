set :stage, :production
set :rails_env, 'production'
set :chruby_ruby, '2.1.3'

role :web, %w{finanzas-cetem.frm.utn.edu.ar}
role :app, %w{finanzas-cetem.frm.utn.edu.ar}
role :db, %w{finanzas-cetem.frm.utn.edu.ar}

server 'finanzas-cetem.frm.utn.edu.ar', user: 'deployer', roles: %w{web app db}
