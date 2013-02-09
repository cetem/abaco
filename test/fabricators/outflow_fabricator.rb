Fabricator(:outflow) do
  user_id       { Fabricate(:user).id }
  kind          { Outflow::KIND.except(:refunded).values.sample }
  comment       { Faker::Lorem.sentence }
  amount        { (100.0 * rand) }
  bill          { rand(999999999999) }
  operator_id   { |attrs| Fabricate(:user).id if attrs[:kind] == Outflow::KIND[:upfront] }
end
