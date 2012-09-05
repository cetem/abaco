Fabricator(:outflow) do
  user_id { rand(100) }
  kind { Outflow::KIND.except(:refunded).values.sample }
  comment { Faker::Lorem.sentence }
  amount { (1000 * rand).round(2) }
  bill { rand(999999999999) }
  operator_id { |attrs| rand(100) if attrs[:kind] == Outflow::KIND[:upfront] }
end
