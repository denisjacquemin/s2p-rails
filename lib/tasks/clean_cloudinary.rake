desc "Clean Cloudinary"
task :clean_cloudinary => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)

  # result = Cloudinary::Api.resources(options = {})
  result = Cloudinary::Search
            .sort_by('uploaded_at','desc')
            .execute


  debugger
  
end