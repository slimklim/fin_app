# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
require 'lorem_ipsum_amet'

User.create(name: "trololo", email: "q@q.q",
  password: "111111", password_confirmation: "111111", email_confirmed: true, confirm_token: nil)

300.times do |i|
  value = rand(1..99)
  credit = rand(2) == 0
  date = Date.new(2016, 8, rand(1..31))
  comment = LoremIpsum.random[0..300]
  tag = comment.split[rand(3)]
  id = User.find_by(email: "q@q.q")[:id]
  Operation.create(user_id: id, value: value, credit: credit, date: date, tag: tag, comment: comment)
end