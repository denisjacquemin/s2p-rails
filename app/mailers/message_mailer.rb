class MessageMailer < ApplicationMailer
  include Roadie::Rails::Automatic

  def message_email(to, message, title, content)
    @message = message
    @message.title = title
    @message.content = content
    
    #attachments['konecto_logo.png'] = File.read(Rails.root.join("app","assets", "images","konecto_logo.png"))
    #attachments.inline[@message.mfiles[0].filename] = open('https:' + @message.mfiles[0].file_url) {|f| f.read }
    # if @message.mfiles.any?
    #   byebug
    #   file = File.open(('https:' + @message.mfiles[0].file_url)
    #   attachments.inline[@message.mfiles[0].filename] = file.read
    # end


    # <!-- A Real Hero (and a real human being) -->
    # <% #if @message.mfiles.any? %>
    # <% #      <p><%= image_tag attachments[@message.mfiles[0].filename].url %></p><!-- /hero -->
    # <% #end %>
    # <!--<td><%= image_tag attachments['logo.png'].url %></td>-->

    x_smptapi_hash = {}
    x_smptapi_hash['unique_args'] = { mid: @message.id, sid: @message.school_id }
    x_smptapi_hash['to'] = to if to.kind_of?(Array) # if to argument is an array build 'to' X-SMTPAPI list
    x_smptapi_hash['to'] = [to] if to.kind_of?(String)

    codes = []
    if content.include?('[code]')
      # "sub": {
      #   "[code]": [
      #     "John",
      #     "Jane"
      #   ]
      # }
      to.each do |email|
        # for current email gets all students to build the codes
        students_containing_email_string = Student.where("emails LIKE ?", "%#{email}%").by_school(@message.school_id)
        students = students_containing_email_string.select do |s|
          emails = s.emails.split(' ').collect(&:strip);
          emails.include?(email)
        end

        codes << students.map do |student|
          "<li>#{student.fullname}: #{student.code}</li>"
        end.join || ""
      end
    end

    unless codes.blank?
      x_smptapi_hash['sub'] = {
        "[code]": codes
      }
    end
    headers "X-SMTPAPI" => x_smptapi_hash.to_json

    from = "#{@message.school_name} - #{@message.author.fullname}" + '<' + 'konecto@konectoapp.com' + '>' || 'konecto@konectoapp.com'
    reply_to = @message.author.fullname + '<' + @message.author.email + '>' || 'konecto@konectoapp.com'
    resp = mail(from: from, to: 'konecto@konectoapp.com', subject: title, reply_to: reply_to )
    logger.info "message_email response: #{resp.inspect}"
  end
end
