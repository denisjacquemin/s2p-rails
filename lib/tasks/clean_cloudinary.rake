desc "Clean Cloudinary"
task :clean_cloudinary => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  result = Cloudinary::Api.resources(options = {})
  result = Cloudinary::Search.execute


  debugger
  
end