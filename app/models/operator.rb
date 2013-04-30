class Operator < ActiveResource::Base
  self.site = "http://#{APP_CONFIG['print_hub_data']['site']}"
  self.user = APP_CONFIG['print_hub_data']['user']
  self.password = APP_CONFIG['print_hub_data']['password']
  self.element_name = 'user'
end
