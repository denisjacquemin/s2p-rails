# write a task that replace all occurence of s2p\" by s2p2\" in School.send_code_template

# Path: lib/tasks/change_djsn_todsjn2.rake
desc "Change djsn to dsjn2"
task :change_djsn_todsjn2 => :environment do
    # AlertAdminMailer.send_alert("Send Scheduled Messages Running #{10.minutes.ago} <> #{Time.current}").deliver_later
    
    Rails.logger = Logger.new(STDOUT)
    
    @schools = School.all
    @schools.each do |school|
        Rails.logger.debug "school.id #{school.id}"
        Rails.logger.debug "school.send_code_template #{school.send_code_template}"
        # replace all occurence of s2p\" by s2p2\" in School.send_code_template, include character \ in the string to replace
        school.send_code_template = school.send_code_template.gsub("s2p\"", "s2p2\"")
        # school.send_code_template = school.send_code_template.gsub("djsn", "dsjn2")
        Rails.logger.debug "school.send_code_template #{school.send_code_template}"
        school.save
    end
end







