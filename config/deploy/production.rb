set :stage, :production

role :all, %w{finanzas-cetem.frm.utn.edu.ar}

server 'finanzas-cetem.frm.utn.edu.ar', user: 'deployer', roles: %w{web app db}
