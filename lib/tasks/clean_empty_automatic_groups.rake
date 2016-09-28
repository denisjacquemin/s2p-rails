desc "Clean Empty automatic groups"
task :clean_empty_automatic_groups => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  Group.where(updatable: false).each do |g|
    g.clean_automatic_group
  end
end
