desc "Set hasform column value for each message"
task :set_has_form_column_value => :environment do
  ActiveRecord::Base.logger = Logger.new(STDOUT)
  Message.pluck(:id, :formdata).each do |m|
    if (not m[1].blank? and not m[1] === "[]")
      Message.update(m[0], has_form: true)
    end
  end
end
