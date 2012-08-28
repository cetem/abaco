Fabricator(:setting) do
  title { Faker::Lorem.sentence }
  var   { |attrs| attrs[:title].downcase.split.join('_') }
  value { rand(100).to_s }
end
