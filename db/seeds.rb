# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

super_admin = CreateSuperAdminService.new.call
puts 'SUPER ADMIN USER CREATED: ' << super_admin.email

app = Rpush::Apns::App.new
app.name = "ios_app"
app.certificate = File.read("config/sandbox.pem")
app.environment = "sandbox" # APNs environment.
app.password = Rails.application.secrets.ios_push_cert_password
app.connections = 1
app.save!

appA = Rpush::Gcm::App.new
appA.name = "android_app"
appA.auth_key = "AIzaSyBQJhjsDel6AIoryzdbDx-AuUZd6qWXyfQ"
appA.connections = 1
appA.save!
