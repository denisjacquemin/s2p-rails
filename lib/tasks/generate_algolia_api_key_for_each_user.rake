desc "Generate Algolia Api Key for each user"
task :generate_algolia_api_key_for_each_user => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  User.all.each do |u|
    @create_algolia_api_key_service = CreateAlgoliaApiKeyService.new(u)
    @create_algolia_api_key_service.generate_key
  end
end
