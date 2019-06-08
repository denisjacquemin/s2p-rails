class MessageMailer < ApplicationMailer
  include Roadie::Rails::Automatic

  def message_email(emails_data_to_process, message, title, content)
    @message = message
    @message.title = title
    @message.content = content

    to = []
    codes = []
    emails_encrypt = []
    studentids = []
    emails_data_to_process.each do |email_to_process|
      to.push(email_to_process[:email])
      codes.push(email_to_process[:code])
      emails_encrypt.push(email_to_process[:email_encrypted])
      studentids.push(email_to_process[:student_id])
    end

    puts "######### to.size: #{to.size}"
    puts "######### codes.size: #{codes.size}"
    puts "######### emails_encrypt.size: #{emails_encrypt.size}"

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

    amount_to_pay = []
    # if content.include?('[code]')
      # "sub": {
      #   "[code]": [
      #     "John",
      #     "Jane"
      #   ]
      # }

    x_smptapi_hash['sub'] = {}.tap do |my_hash|
      my_hash["[code]"] = codes unless codes.blank?
      my_hash["-email_encrypt-"] = emails_encrypt unless emails_encrypt.blank?
      my_hash["-studentids-"] = studentids unless studentids.blank?
    end


    logger.info "X-SMTPAPI prety output: #{JSON.pretty_generate(x_smptapi_hash)}"


    # unless codes.blank?
    #   x_smptapi_hash['sub'] = {
    #     "[code]": codes,
    #     "-email_encrypt-": emails_encrypt
    #   }
    # end
    headers "X-SMTPAPI" => JSON.generate(x_smptapi_hash)
    no_reply = "no-reply@konectoapp.com"

    from = %Q["#{@message.school_name}"] + '<' + 'konecto@konectoapp.com' + '>' || 'konecto@konectoapp.com'

    if [10, 67].include? @message.school_id 
      from = %Q["#{@message.school_name}"] + '<' + no_reply + '>' || no_reply
    end

    reply_to = 'konecto@konectoapp.com'
    if [10, 67].include? @message.school_id 
      reply_to = no_reply
    end
    if @message.author.display_email_address
      reply_to = @message.author.fullname + '<' + @message.author.reply_to + '>' || 'konecto@konectoapp.com'
    end

    
    resp = mail(from: from, to: 'konecto@konectoapp.com', subject: title, reply_to: reply_to )
    logger.info "message_email response: #{resp.inspect}"
  end

  rescue_from(StandardError) do |exception|
   logger.info "error raised in message_email: #{exception}"
   logger.info exception.backtrace
  end

  private
    def get_students_code_by_email(students)
      # for a given email, gets the corresponding students scoped to the school_id
      # for each students, get the codes
      codes_li_tags = []
      students.each do |student|
        codes_li_tags << "<li>#{student.firstname} #{student.lastname}: #{student.code}</li>"
      end
      codes_li_tags = "" if codes_li_tags.empty?
      codes_li_tags
    end
end
