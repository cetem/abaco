class Operator < ActiveResource::Base
  self.site = APP_CONFIG['print_hub_data']['site']
  self.user = APP_CONFIG['print_hub_data']['user']
  self.password = APP_CONFIG['print_hub_data']['password']
  self.include_root_in_json = false
  self.element_name = 'user'
end
