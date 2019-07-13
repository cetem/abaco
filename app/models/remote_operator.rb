class RemoteOperator < ActiveResource::Base
  self.site = "http://#{SECRETS['print_hub_data']['site']}"
  self.user = SECRETS['print_hub_data']['user']
  self.password = SECRETS['print_hub_data']['password']
  self.element_name = 'user'
  self.primary_key = :abaco_id

  def to_s
    try(:label)
  end
end
