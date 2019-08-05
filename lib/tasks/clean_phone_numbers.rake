desc "Clean Phones Numbers"
task :clean_phone_numbers => :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    
    school = School.find 143
    
    school.students.each do |s|
    
        phones = s.phones

        # phones.all.map(&:number)
        phonesMerged = phones.map do |phone|
            phonieObj = Phonie::Phone.parse(phone.number, country_code: '32')&.to_s
        end.flatten.compact.uniq

        phonedToInsert = phonesMerged.map do |number|
            Phone.new number: number unless number.nil?
        end

        s.phones = phonedToInsert
        s.save
    end
    
    

end
