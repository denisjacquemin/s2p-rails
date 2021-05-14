# invokation: rails delete_classroom_for_a_given_school[1]

# This task aim to removes all files in cloudinary wich are not linked to any messages in DB

desc "Clean unused files in Cloudinary"
task :clean_unused_files_in_cloudinary => :environment do |task|

  # useful help at 
  # https://support.cloudinary.com/hc/en-us/articles/203678042-How-to-list-all-resources-older-than-a-specific-date-
  # https://support.cloudinary.com/hc/en-us/articles/205714121-How-do-I-browse-through-all-the-resources-in-my-account-using-the-API-

  year = 2021
  month = 03
  day = 30

  chuck_size = 500

  # get all resources starting at a given date
  resources = Cloudinary::Api.resources(start_at:Time.new(year,month,day), direction:"desc", max_results: chuck_size)

  # for all resources found, check if the public_id exist as AttachinaryFile
  # if not it should be deleted
  total_found = 0
  to_delete = 0
  to_keep = 0

  public_ids_to_delete = []

  puts "count: #{resources["resources"].count}"

  resources["resources"].each do |resource|
    total_found = total_found + 1
    files = AttachinaryFile.where(public_id: resource["public_id"])
    files.each do |file|
      to_keep = to_keep + 1
      puts "found #{file.public_id}"
    end
    if files.empty?
      to_delete = to_delete + 1
      # puts "#{resource["public_id"]} should be deleted"
      public_ids_to_delete.push(resource["public_id"])
      # puts 
    end
  end


  while resources.has_key?("next_cursor") do

    resources = Cloudinary::Api.resources(start_at:Time.new(year,month,day), direction:"desc", max_results: chuck_size, :next_cursor => resources["next_cursor"])


    resources["resources"].each do |resource|
      total_found = total_found + 1
      files = AttachinaryFile.where(public_id: resource["public_id"])
      files.each do |file|
        to_keep = to_keep + 1
        puts "found #{file.public_id}"
      end
      if files.empty?
        to_delete = to_delete + 1
        public_ids_to_delete.push(resource["public_id"])
        #puts "#{resource["public_id"]} should be deleted"
      end
    end
  end

  puts "total_found: #{total_found}"
  puts "to_delete: #{to_delete}"
  puts "to_keep: #{to_keep}"
  puts "total attachinary in db #{AttachinaryFile.count}"

  # puts "public_ids_to_delete: #{public_ids_to_delete.count} #{public_ids_to_delete}"


  unless public_ids_to_delete.empty?
    public_ids_to_delete.each_slice(100).to_a.each do |ids|
      Cloudinary::Api.delete_resources(ids) 
    end
  end
  

end
