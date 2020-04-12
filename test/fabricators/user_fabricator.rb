Fabricator(:user) do
  name      { Faker::Name.first_name }
  lastname  { Faker::Name.last_name }
  email     { |attrs|
    Faker::Internet.email(name: I18n.transliterate(attrs[:name]))
  }
  password  { Faker::Lorem.sentence }
  password_confirmation { |attrs| attrs[:password] }
  role  { :admin }
end
