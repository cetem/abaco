ph_data = APP_CONFIG['print_hub_data']
site = "#{ph_data['user']}:#{ph_data['password']}@#{ph_data['site']}"
date_regexp = '\d{4}\-\d{1,2}\-\d{1,2}'

@generic_operator = {
  id: '1',
  label: 'Operator Operator',
  informal: 'Operator',
  admin: 'true'
}

@operator_shifts = []
days = 27.days.ago
id = 1

3.times do
  @operator_shifts << {
    id: id, 
    start: days, 
    finish: days + 5.hours, 
    created_at: days
  }
  id += 1
  days += 1.days
end

stub_request(
  :get, /#{site}\/users\/\d+.json/
).with(
  headers: { 'Accept'=>'application/json' }
).to_return(
  body: @generic_operator.to_json
)

stub_request(
  :get, "#{site}/users/autocomplete_for_user_name.json?q=operator"
).with(
  headers: { 'Accept'=>'application/json' }
).to_return(
  body: @generic_operator.to_json
)

stub_request(
  :put, /#{site}\/users\/\d+\/pay_shifts_between.json\?
    finish=#{date_regexp}&start=#{date_regexp}/x
).with(
  headers: { 'Content-Type'=>'application/json' }
).to_return(
  status: 200
)

stub_request(
  :get, /#{site}\/shifts.json\?
    pay_pending_shifts_for_user_between\[finish\]=#{date_regexp}&
    pay_pending_shifts_for_user_between\[start\]=#{date_regexp}&
    pay_pending_shifts_for_user_between\[user_id\]=\d+/x
).with(
  headers: { 'Accept' => 'application/json' }
).to_return(
  body: @operator_shifts.to_json
)

