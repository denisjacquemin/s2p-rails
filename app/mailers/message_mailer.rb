class MessageMailer < ApplicationMailer
  include Roadie::Rails::Automatic

  def message_email(to, message)
    @message = message
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

    from = @message.author.fullname + '<' + 'konecto@konectoapp.com' + '>' || 'konecto@konectoapp.com'
    reply-to = @message.author.fullname + '<' + @message.school.email + '>' || 'konecto@konectoapp.com'
    mail(from: from, to: to, subject: @message.title, reply_to: reply-to )
  end
end
