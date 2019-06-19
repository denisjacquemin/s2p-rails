class ConfirmFormSubmittedMailer < ApplicationMailer
  include Roadie::Rails::Automatic

  def send_confirmation(to, form_id)
    @form = Form.find form_id
    unless @form.nil?
      message = Message.where(muuid: @form.muuid).first

      school_name = ""
      school_name = message.school.name unless message.nil?

      x_smptapi_hash = {}
      x_smptapi_hash['to'] = to if to.kind_of?(Array) # if to argument is an array build 'to' X-SMTPAPI list
      x_smptapi_hash['to'] = [to] if to.kind_of?(String)
      headers "X-SMTPAPI" => x_smptapi_hash.to_json
      mail(from: "#{school_name}<no-reply@konectoapp.com>", to: 'konecto@konectoapp.com', subject: "Confirmation: #{message.title}" )
    end


  end

  rescue_from(StandardError) do |exception|
   logger.info "error raised in message_email: #{exception}"
   logger.info exception.backtrace
  end

end
