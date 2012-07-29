Fabricator(:outflow) do
  user_id { rand(100) }
  kind { Outflow::KIND.values.sample }
  comment { Faker::Lorem.sentences(1).join }
  amount { (1000 * rand).round(2) }
  operator_id { |attrs| rand(100) if attrs[:kind] == Outflow::KIND[:upfront] }
end
