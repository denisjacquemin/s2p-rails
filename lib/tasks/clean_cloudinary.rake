desc "Clean Cloudinary"
task :clean_cloudinary => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  Cloudinary::Api.resources(options = {})
end