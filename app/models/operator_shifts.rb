class OperatorShifts < ActiveResource::Base
  self.site = "http://#{APP_CONFIG['print_hub_data']['site']}"
  self.user = APP_CONFIG['print_hub_data']['user']
  self.password = APP_CONFIG['print_hub_data']['password']
  self.element_name = 'shifts'

  def self.convert_hash_in_open_struct(shifts)
    shifts.map do |s|
      OpenStruct.new(
        start: (s['start'].present? ? Time.parse(s['start']) : ''),
        finish: (s['finish'].present? ? Time.parse(s['finish']) : ''),
        paid: s['paid']
      )
    end
  end
end
