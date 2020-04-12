ph_data = SECRETS['print_hub_data']
site = "#{ph_data['site']}"
date_regexp = '\d{4}\-\d{1,2}\-\d{1,2}'
datetime_regexp = '\d{4}\-\d{1,2}\-\d{1,2} \d{1,2}:\d{2}:\d{2} -\d{4}'


@generic_operator = {
  id:       '1',
  abaco_id: '19ad724d-118e-4908-b8f5-2800a046bb2b',
  label:    'Operator Operator',
  informal: 'Operator',
  admin:    'true'
}

@operator_shifts = []
days = 27.days.ago

3.times do |i|
  @operator_shifts << {
    id:         i,
    start:      days,
    finish:     days + 5.hours,
    created_at: days
  }
  days += 1.days
end

stub_request(
  :get, /\/users\/(\d+|#{::UUID_REGEX})\.json/
).with(
  headers: { 'Accept'=>'application/json' }
).to_return(
  body: @generic_operator.to_json
)

stub_request(
  :get, /\/users\/autocomplete_for_user_name\.json.*/
).with(
  headers: { 'Accept'=>'application/json' }
).to_return(
  body: @generic_operator.to_json
)

stub_request(
  :patch, /.*pay_shifts_between\.json.*/i
).with(
  headers: { 'Content-Type'=>'application/json' }
).to_return(
  status: 200
)

stub_request(
  :get, /\/shifts\.json\?pay_pending_shifts_for_user_between/
).with(
  headers: { 'Accept' => 'application/json' }
).to_return(
  body: @operator_shifts.to_json
)

stub_request(
  :get, /#{site}\/shifts\/json_paginate\.json/
).with(
  headers: { 'Accept' => 'application/json' }
).to_return(
  body: @operator_shifts.to_json
)

stub_request(
  :get, /\/users\/current_workers\.json/
).with(
  headers: { 'Accept' => 'application/json' }
).to_return(
  body: [
    @generic_operator,
    {
      id: '2',
      label: 'Yoda Master',
      informal: 'Yoda',
      admin: 'true'
    }
  ].to_json
)

stub_request(
  :post, /\/shifts\.json/
).with { |request|
  request.body.match?(
    /\"start\":\"#{datetime_regexp}\",\"finish\":\"#{datetime_regexp}\"/
) }.to_return(
  status: 200
)
