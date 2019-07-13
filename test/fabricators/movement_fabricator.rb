Fabricator(:movement) do
  user_id         { Fabricate(:user).id }
  # kind            { Movement.kinds.slice(:refunded).keys.sample }
  kind            { [:library, :tops_rings, :paper, :toner, :maintenance].sample }
  comment         { Faker::Lorem.sentence }
  amount          { (100.0 * rand) }
  bill            { rand(999999999999) }
  # operator_id     { |attrs| Fabricate(:user).id }
  to_account_type { 'Provider' }
  to_account_id   { Fabricate(:provider).id }
  bought_at       { Date.today }
  with_incentive  { [true, false].sample }
end
