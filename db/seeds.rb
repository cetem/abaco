user = User.new(
  name: 'Admin',
  lastname: 'Admin',
  email: 'admin@abaco.com',
  password: '123456',
  password_confirmation: '123456',
  role: :admin
)

puts(user.save ? 'User [OK]' : user.errors.full_messages.join("\n"))

begin
  Setting.create!(
    title: 'Pay per administrator hour',
    var: 'pay_per_administrator_hour',
    value: '12'
  )

  Setting.create!(
    title: 'Pay per operator hour',
    var: 'pay_per_operator_hour',
    value: '10'
  )
rescue => ex
  p ex
else
  puts 'Setting [OK]'
end