Fabricator(:box) do
  name { Faker::Name.first_name }
  multi_use :default_cashbox
end
