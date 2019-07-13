Fabricator(:account) do
  name { Faker::Name.first_name }
end
