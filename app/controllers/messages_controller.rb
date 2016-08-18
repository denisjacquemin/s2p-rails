class MessagesController < ApplicationController
  include ActionView::Helpers::TextHelper # for truncate
  include Notification

  before_action :authenticate_user!
  before_action :set_message, only: [:show, :edit, :update, :publish, :unpublish, :send_for_approval, :accept, :reject, :update_groups, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  # GET /messages
  # GET /messages.json
  def index
    @messages = policy_scope(Message).where(school_id: current_school.id).order(created_at: :desc)
    authorize @messages
    @school_id = current_school
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    authorize @messages
  end

  # GET /messages/new
  def new
    @message = Message.new
    @mfile = Mfile.new
    authorize @message
  end

  # GET /messages/1/edit
  def edit
    authorize @message
    @mfile = Mfile.new
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)
    authorize @message
    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    @message.groups = submitted_groups_ids.map(&:to_i) if submitted_groups_ids.present?

    submitted_students_ids = params[:student][:id] unless params[:student].nil?
    @message.students = submitted_students_ids

    @message.author = current_user

    unless current_user.superadmin?
      @message.school_id = current_school.id
    end

    respond_to do |format|
      if @message.save
        format.html { redirect_to edit_message_path(@message), notice: 'Le message a été créé avec succès.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html {
          @mfile = Mfile.new
          render :new
        }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    authorize @message

    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    if submitted_groups_ids.present?
      @message.groups = submitted_groups_ids.map(&:to_i)
    else
      @message.groups = []
    end

    submitted_students_ids = params[:student][:id] unless params[:student].nil?
    @message.students = submitted_students_ids

    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to edit_message_path(@message), notice: 'Le message a été mis à jour.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html {
          @mfile = Mfile.new
          render :edit
        }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_groups
    authorize @message
    # before update, compares the actual groups for the message against the submitted list
#    actual_groups_ids = @message.groups
    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
#    submitted_groups_ids = [] if submitted_groups_ids.nil?

    # get the ids to be removed (remove_groups)
#    actual_groups_to_delete = actual_groups_ids - submitted_groups_ids.map(&:to_i)

    # check if submited groups are not yet in db
#    submitted_groups_to_add = submitted_groups_ids.select { |g| !actual_groups_ids.include?(g.to_i) }

#    Message.add_groups(@message.id, submitted_groups_to_add.map(&:to_i)) if submitted_groups_to_add.any?
#    Message.remove_groups(@message.id, actual_groups_to_delete) if actual_groups_to_delete.any?

    @message.groups = submitted_groups_ids
    @message.save

    redirect_to edit_message_path(@message, t: 'groups'), notice: 'Le message a été mis à jour.'
  end

  def publish
    authorize @message
    @message.published!
    if @message.update(publish_date: DateTime.now)
      groups = @message.groups
      if groups.present? or @message.students.present?
        students = Student.by_groups(groups) unless groups.nil?
        students = students + Student.find(@message.students) unless @message.students.nil?
        students = students.uniq
        student_codes = students.map {|s| s.code }
        codes = (student_codes +  Group.find(groups).pluck(:code)).flatten

        devicesIOS = Device.active.ios.by_codes(codes)
        build_ios_notifications(@message, devicesIOS) if @message.send_to_app

        #@message.notify_ios(devicesIOS, truncate(@message.title, :length => 200))

        devicesAndroid = Device.active.android.by_codes(codes)
        build_android_notifications(@message, devicesAndroid) if @message.send_to_app

        build_emails(students, @message) if @message.send_by_email
      end
        # devicesIOS = Device.active.ios.by_codes(student_codes)
        # devicesIOS.each { |device|
        #   # check if device.token is present in Rpush::Apns::Feedback
        #   n = Rpush::Apns::Notification.new
        #   n.app = Rpush::Apns::App.find_by_name("ios_app")
        #   n.device_token = device.registration_id # 64-character hex string
        #   n.alert = @message.title
        #   n.data = {
        #     "title": truncate(@message.title, :length => 200),
        #     "message_id": @message.id,
        #     "content-available": 1,
        #     "badge": 1
        #   }
        #   begin
        #     n.save!
        #   rescue ActiveRecord::RecordInvalid
        #     logger.debug "Rpush::Apns::Notification save failed for #{device.token} + #{device.inspect}"
        #   end
        # }
        # devicesAndroid = Device.active.android.by_codes(student_codes)
        # devicesAndroid.each { |device|
          # registration_ids = Device.active.android.by_codes(student_codes).map{|device| device.registration_id}
          # unless registration_ids.nil?
          #   n = Rpush::Gcm::Notification.new
          #   n.app = Rpush::Gcm::App.find_by_name("android_app")
          #   n.registration_ids =
          #   n.data = { "message_id": @message.id }
          #   n.priority = 'normal'      # Optional, can be either 'normal' or 'high'
          #   n.content_available = true # Optional
          #   # Optional notification payload. See the reference below for more keys you can use!
          #   n.notification = { title: truncate(@message.title, :length => 200).force_encoding("utf-8"),
          #                      icon: 'myicon'
          #                    }
          #   n.save!
          # end
        # }
      redirect_back fallback_location: messages_url, notice: 'Message publié avec succès'
      #redirect_to messages_url, notice: 'Message publié avec succès'
    else
      render :edit
    end
  end

  def unpublish
    authorize @message
    @message.draft!
    if @message.update(publish_date: nil)
      redirect_back fallback_location: messages_url, notice: 'Message dépublié avec succès'
    else
      render :edit
    end
  end

  def send_for_approval
    authorize @message
    @message.waiting_for_approval!
    # send notification to admins
    codes = @message.school.admins.map{|u| u.code}

    devicesIOS = Device.active.ios.by_codes(codes)
    alert = "#{@message.author.firstname} demande une approbation: #{@message.title}"
    send_ios_notifications(alert, devices) unless devicesIOS.nil?
    devicesAndroid = Device.active.android.by_codes(codes)
    build_android_notifications(@message, devicesAndroid) unless devicesAndroid.nil?

    if @message.save
      redirect_back fallback_location: messages_url, notice: 'Message envoyé pour approbation avec succès'
    else
      render :edit
    end
  end

  def accept
    authorize @message
    @message.approval_accepted!

    codes = [] <<  @message.author.code

    devicesIOS = Device.active.ios.by_codes(codes)
    alert = "Message approuvé: #{@message.title}"
    send_ios_notifications(alert, devices) unless devicesIOS.nil?
    devicesAndroid = Device.active.android.by_codes(codes)
    build_android_notifications(@message, devicesAndroid) unless devicesAndroid.nil?

    if @message.save

      redirect_back fallback_location: messages_url, notice: 'Message accepté'
    else
      render :edit
    end
  end

  def reject
    authorize @message
    @message.approval_refused!
    # send notification to author
    if @message.save
      redirect_back fallback_location: messages_url, notice: 'Message refusé'
    else
      render :edit
    end
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
    authorize @message
    @message.destroy
    respond_to do |format|
      format.html { redirect_to messages_url, notice: 'Le message a été effacé.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_params
      params.require(:message).permit(:title, :content, :school_id, :mtype, :when, :send_by_email, :send_to_app, :skip_send_by_email)
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mfile_params
      params.require(:mfile).permit(:filename, :file_url, :school_id, :message_id)
    end

    def build_emails(students, message)
      emails = students.collect { |s|
        s.emails.split(' ') if (s.sent_message_by_email or message.skip_send_by_email) and !s.emails.nil?
      }.compact.flatten.uniq      # build an array of emails

      content = message.content
      emails.each do |e|
        message.content = replace_code_smart_tag(students, e, content) if content.include?('[code]')
        MessageMailer.message_email(e, message).deliver
      end

    end

    def replace_code_smart_tag(students, email, content)
      codes = ""
      students.each do |s|
        #puts "#{s.code} found for student #{s.fullname} and email #{email} $$$$ (#{s.inspect})"
        codes << "<li>#{s.fullname}: #{s.code}</li>" if s.emails.present? and s.emails.include?(email)
      end

      content.gsub('[code]', "<ul>#{codes}</ul>")
    end
end
