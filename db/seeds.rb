# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

super_admin = CreateSuperAdminService.new.call
puts 'SUPER ADMIN USER CREATED: ' << super_admin.email

School.create(name: 'Ecole demo') if !School.exists?(name: 'Ecole demo')

# old
if !Rpush::Apns::App.exists?(name: "ios_app")
  app = Rpush::Apns::App.new
  app.name = "ios_app"
  app.certificate = File.read("config/" + Rails.application.secrets.apns_cert_filename) # https://github.com/rpush/rpush/wiki/Generating-Certificates
  app.environment = Rails.application.secrets.apns_env # APNs environment.
  app.password = Rails.application.secrets.ios_push_cert_password
  app.connections = 1
  app.save!
end

# new
if !Rpush::Apnsp8::App.exists?(name: "ios_app")
  app = Rpush::Apnsp8::App.new
  app.name = "ios_app"
  app.apn_key = File.read("config/" + Rails.application.secrets.apnsp8_cert_filename)
  app.environment = Rails.application.secrets.apns_env # APNs environment.
  app.apn_key_id = Rails.application.secrets.apnsp8_key_id # This is the Encryption Key ID provided by apple
  app.team_id = Rails.application.secrets.apnsp8_team_id # the team id - e.g. ABCDE12345
  app.bundle_id = Rails.application.secrets.apnsp8_bundle_id # the unique bundle id of the app, like com.example.appname
  app.connections = 1
  app.save!
end

if !Rpush::Gcm::App.exists?(name: "android_app")
  appA = Rpush::Gcm::App.new
  appA.name = "android_app"
  appA.auth_key = Rails.application.secrets.gcm_auth_key
  appA.connections = 1
  appA.save!
end
