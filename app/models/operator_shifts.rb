class OperatorShifts < ActiveResource::Base
  self.site = "http://#{SECRETS['print_hub_data']['site']}"
  self.user = SECRETS['print_hub_data']['user']
  self.password = SECRETS['print_hub_data']['password']
  self.element_name = 'shifts'

  def self.convert_hash_in_open_struct(shifts)
    shifts.map do |shift|
      s = OpenStruct.new(shift)
      s.start = Time.parse(s.start) if s.start.present?
      s.finish = Time.parse(s.finish) if s.finish.present?

      s
    end
  end

  def self.get_best_fortnights_for_users
    shifts =  find(:all, params: {
      pay_pending_shifts_for_user_between: {
        start: 1.month.ago.to_date, finish: Date.today
      }
    })

  end
end
