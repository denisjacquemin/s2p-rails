class MessagesController < ApplicationController

  # skip_before_filter :verify_authenticity_token, only: [:save_form]
  before_action :authenticate_user!, except: [:show, :save_form, :refresh_qr]
  before_action except: [:show, :save_form, :refresh_qr] do
    helpers.authorize_current_school(current_user, current_school.id)
  end
  before_action :set_message, only: [:update, :update_amount_to_pay, :publish, :unpublish, :republish, :send_for_approval, :accept, :reject, :update_groups, :destroy, :add_photo, :update_formdata, :export_formdata, :billed_students_list]

  # before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  # GET /messages
  # GET /messages.json
  def noalgolia_index
    @messages = policy_scope(Message).where(school_id: current_school.id).order(updated_at: :desc)
    authorize @messages
    @school_id = current_school
  end

  def index
    @algolia_search_api_key = current_user.algolia_search_api_key
    @current_user_role = current_user.role
    @current_school = current_school  
    @current_school_id = @current_school.id
    # @current_user = current_user
    @workflow_active = @current_school.validation_workflow_active
    @latest_messages = policy_scope(Message).includes(:author).where(school_id: current_school.id).order(updated_at: :desc).limit(12).pluck(:id, :title, :has_form, :content, "CONCAT_WS(' ', users.firstname, users.lastname)", :updated_at, :status, :scheduled_publish)
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    @message = Message.find_by_muuid(params[:uuid])
    if @message
      @title = @message.title
      @content = @message.content

      if @message.school.allow_translation
        project_id = ENV["CLOUD_PROJECT_ID"]
        translate = Google::Cloud::Translate.new project: project_id
        @translation_code = ""
        @languages = translate.languages('fr')
        if params[:translate] and params[:translate][:code] != ""
          @title, @content = getTranslations(params[:translate][:code], @title, @content, @message.id, @message.updated_at, @message.school_id, translate)
          @translation_code = params[:translate][:code]
        end
      end

      students_names = ""
      # params[:e] is the email encrypted
      if (params[:e].present?) # if not, it should still works
        #@email_encrypted = params[:e]
        @email = params[:e] #Student.email_decrypt(@email_encrypted)
        students_names_array = @message.get_students_names_by_email(@email) if @email.present?
        students_names = students_names_array.flatten.uniq.compact.join ', ' if students_names_array.any?
      end
      # params[:s] is the list of students names encrypted
      if (params[:s].present?)
        students_names = params[:s]
      end

      # build transaction only if message.amount is present
      # if @message.amount_to_pay_cents > 0
      #   @transactionId = build_payconiq_transaction_id(@message)
      #   Payment.create(school_id: @message.school_id, message_id: @message.id, pq_transaction_id: @transactionId, price_cents_cents: @message.amount_to_pay_cents, pq_status: 'INITIATED', students_names: students_names, communication: @message.billing_description)
      # end
  end
    render layout: "show"
  end
  def save_form
    j = JSON.parse params[:message_form_formdata]


    j.prepend({label: 'horodateur', value: I18n.l(Time.now.to_datetime().in_time_zone, format: :excel)})
    @form = Form.new(muuid: params[:muuid], formdata: JSON.generate(j))

    @form.save

    # if params[:s] is present, send email confirmation to each email corresponding to that :s student id
    if params[:s].present?
      student_id = params[:s]
      emails = StudentEmail.where(student_id: student_id).pluck(:email)
      if emails.any?
        ConfirmFormSubmittedMailer.send_confirmation(emails, @form.id).deliver_later
      end
    end
  end

  # GET /messages/new
  def new
    @message = Message.new()
    @message.message_categories = MessageCategory.by_school(current_school.id) if current_school.iscity?
    authorize @message
  end

  # GET /messages/1/edit
  def edit
    @message = Message.includes([:author, :school, :photo_files, :succeeded_payments, school: :accounts]).find(params[:id])
    authorize @message

    all_email_recipients = EmailRecipient.where(message_id: @message.id).order(created_at: :desc)
    
    @email_delivered = all_email_recipients.select{|aer| aer.status == 'delivered'}.uniq{|ed| ed.students }
    @email_recipients = all_email_recipients.select{|aer| aer.status == 'open'}.uniq{|ed| ed.students }
    @opens_by_mobile = all_email_recipients.select{|aer| aer.status == 'open_by_mobile'}.uniq{|ed| ed.students }
    @email_errors = all_email_recipients.select{|aer| ['dropped', 'bounce'].include?(aer.status) }.uniq{|ed| ed.students }
    @sms_recipients = all_email_recipients.select{|aer| ['RECEIVED'].include?(aer.status) }.uniq{|sr| sr.students }
    @total_views = @email_recipients.count + @opens_by_mobile.count + @sms_recipients.count
    @showStatsFromEmailRecipients =  @message.updated_at > DateTime.parse('Sun, 10 Nov 2019 13:42:50 +0100')

  end

  def create_sendcode_message
    all_students_selected = params[:all_students].present?

    submitted_students_ids = []
    unless all_students_selected
      submitted_students_ids = params[:student][:id] unless params[:student].nil?
    end


    @message = Message.new({
      title: current_school.send_code_title_template,
      content: current_school.send_code_template,
      send_by_email: true,
      send_to_app: false,
      skip_send_by_email: true,
      author: current_user,
      school_id: current_school.id
    })
    unless all_students_selected
      @message.students = submitted_students_ids.map(&:to_i)
    end

    if all_students_selected
      @message.groups = Group.by_school(current_school.id).where(internal_id: 'all_students').pluck(:id)
    end
    @message.message_categories = MessageCategory.by_school(current_school.id) if current_school.iscity?


    if @message.save
      redirect_to edit_message_path(@message), notice: 'Le message a été créé avec succès.'
    else
      render :students
    end
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
    @message.school_id = current_school.id

    @message.content = Rinku.auto_link(@message.content)


    anchor = params[:active_tab][1..-1] unless params[:active_tab].nil?
    if @message.save
      redirect_to edit_message_path(@message, anchor: anchor), notice: 'Le message a été créé avec succès.'
    else
      render :new
    end
  end

  def add_photo
    if @message.update(add_photo_params)
      redirect_to edit_message_path(@message, anchor: 'cloudinary-tab'), notice: 'Le message a été mis à jour.'
    end
  end

  def update_formdata
    form_due_date = nil
    form_due_date = DateTime.parse(params[:formduedate]) if params[:formduedate].present?

    if @message.update(formdata: params[:message][:formdata], form_due_date: form_due_date)
      redirect_to edit_message_path(@message, anchor: 'formbuilder-tab'), notice: 'Le message a été mis à jour.'
    end
  end

  def billed_students_list
    @students_for_billing = []
    @students_for_billing = Student.default_order.by_groups(@message.groups) unless @message.groups.nil?
    students_form_students_ids = Student.by_ids(@message.students)
    @students_for_billing += students_form_students_ids unless students_form_students_ids.nil?
    @students_for_billing = @students_for_billing.compact.flatten.uniq if @students_for_billing.any?
    @billed_students = @students_for_billing.collect do |sfb|
      bs = BilledStudent.find_by(student_id: sfb.id, message_id: @message.id)
      bs = BilledStudent.new(student_id: sfb.id) if bs.nil?
      bs
    end

    render :layout => false
  end

  def update_amount_to_pay
    authorize @message
    if @message.update(update_amount_to_pay_params)
      redirect_to edit_message_path(@message, anchor: 'billing-tab'), notice: 'Le message a été mis à jour.'
    else
      redirect_to edit_message_path(@message, anchor: 'billing-tab'), error: 'Une erreur est survenue.'
    end
  end

  def export_formdata
    forms = Form.by_muuid(@message.muuid).latest_first
    rows = []
    column_names = Set.new
    forms.each do |form| # for each form get the colum names
      formjson = JSON.parse(form.formdata)
      formjson.each do |column|
        column_name_title = ""
        column_name_title = column['label'].strip unless column['label'].nil?
        column_name_title = column_name_title.gsub(' *', '')
        column_name_title = 'Pas de titre' if column_name_title.blank?
        column_names.add(column_name_title) # if it does't exist yet add column name to columns_names Set
      end
    end

    rows = []

    forms.each do |form| # for each form build row
      formjson = JSON.parse(form.formdata)
      row = []
      column_names.each_with_index do |column_name, index|
        row[index] = ""
        formjson.each do |column|
          # logger.info "current culumn_name: #{column_name} for column: #{column.inspect}"
          # logger.info "#{column['label']} == #{column_name} = #{column['label'] == column_name}"
          column_name_title = ""
          column_name_title = column['label'].strip unless column['label'].nil?
          column_name_title = column_name_title.gsub(' *', '')
          column_name_title = 'Pas de titre' if column_name_title.blank?
          if column_name_title == column_name
            if row[index] === ""
              row[index] = column['value'].to_s
            else
              row[index] += ', ' + column['value'].to_s
            end
          end
        end
      end
      rows.push(row)
    end

    respond_to do |format|
      format.csv {
        options = {
          col_sep: ';',
          headers: true
        }
        csv_data = CSV.generate(options) do |csv|
          csv << column_names.to_a
          rows.each do |r|
            csv << r
          end
        end
        filename_title = ""
        unless @message.title.empty?
          filename_title = @message.title.slice(0..20).parameterize
        end

        send_data csv_data.encode("cp1252", invalid: :replace, undef: :replace),
          filename: "export_#{filename_title}_#{I18n.l(Time.now, format: :short).parameterize}.csv",
          type: 'text/csv; charset=iso-8859-1; header=present'
      }
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    authorize @message
    # case params[:status]
    #   when 'publish'
    #     @message.published!
    # end
    @message_params = message_params

    # handle scheduled_date
    @message.scheduled_publish = Time.zone.parse(params[:scheduled_datetime]).utc unless params[:scheduled_datetime].blank?
    @message.scheduled_publish = '' if params[:scheduled_datetime].blank?
    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    if submitted_groups_ids.present?
      @message.groups = submitted_groups_ids.map(&:to_i)
    else
      @message.groups = []
    end

    submitted_students_ids = params[:student][:id] unless params[:student].nil?
    @message.students = submitted_students_ids

    @message_params[:content] = Rinku.auto_link(@message_params[:content])

    unless params[:change_status] == 'true'
      @message_params[:status] = @message.status
    end
    if @message.update(@message_params)
      redirect_to edit_message_path(@message), notice: 'Le message a été mis à jour.'
    else
      logger.info "error in MessageController.update #{@message.inspect}"
      @message.status = @message.status_was
      render :edit
    end
  end

  def copy
    @message_to_copy = Message.find(params[:id])   

    @message = Message.new()
    @message.title = @message_to_copy.title
    @message.content = @message_to_copy.content
    @message.formdata = @message_to_copy.formdata 
    # @message.photos = @message_to_copy.photos
    @message.school_id = @message_to_copy.school_id
    @message.author = current_user

    if @message.save
      redirect_to edit_message_path(@message), notice: 'Le copie du message a été créé avec succès.'
    else
      redirect_to edit_message_path(@message_to_copy), notice: 'Erreur durant la création de la copie.'
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
    @message.status = 'published'
    if @message.save
      # groups = @message.groups
      # if groups.present? or @message.students.present?
      #   students = Student.by_groups(groups) unless groups.nil?
      #   students = students + Student.find(@message.students) unless @message.students.nil?
      #   students = students.uniq
      #   student_codes = students.map {|s| s.code }
      #   codes = (student_codes +  Group.find(groups).pluck(:code)).flatten
      #
      #   devicesIOS = Device.active.ios.by_codes(codes)
      #   build_ios_notifications(@message, devicesIOS) if @message.send_to_app
      #
      #   #@message.notify_ios(devicesIOS, truncate(@message.title, :length => 200))
      #
      #   devicesAndroid = Device.active.android.by_codes(codes)
      #   build_android_notifications(@message, devicesAndroid) if @message.send_to_app
      #
      #   build_emails(students, @message) if @message.send_by_email
      # end

      redirect_back fallback_location: messages_url, notice: 'Message publié avec succès'
      #redirect_to messages_url, notice: 'Message publié avec succès'
    else
      @message.status = @message.status_was
      render :edit
    end
  end

  def unpublish
    authorize @message
    @message.draft!
    if @message.save
      redirect_back fallback_location: messages_url, notice: 'Message dépublié avec succès'
    else
      render :edit
    end
  end

  def republish
    authorize @message
    @message.status = 'republished'
    if @message.save
      redirect_back fallback_location: messages_url, notice: 'Message réenvoyé avec succès'
    else
      render :edit
    end
  end

  def send_for_approval
    authorize @message
    @message.waiting_for_approval!
    # send notification to admins
    # codes = @message.school.admins.map{|u| u.code}
    #
    # devicesIOS = Device.active.ios.by_codes(codes)
    # alert = "#{@message.author.firstname} demande une approbation: #{@message.title}"
    # data = { "message_id": @message.id }
    # send_ios_notifications(alert, devicesIOS, data) unless devicesIOS.nil?
    # devicesAndroid = Device.active.android.by_codes(codes)
    # build_android_notifications(@message, devicesAndroid) unless devicesAndroid.nil?

    if @message.save
      redirect_back fallback_location: messages_url, notice: 'Message envoyé pour approbation avec succès'
    else
      render :edit
    end
  end

  def accept
    authorize @message
    @message.approval_accepted!

    # codes = [] <<  @message.author.code
    #
    # devicesIOS = Device.active.ios.by_codes(codes)
    # alert = "Message approuvé: #{@message.title}"
    # send_ios_notifications(alert, devicesIOS) unless devicesIOS.nil?
    # devicesAndroid = Device.active.android.by_codes(codes)
    # build_android_notifications(@message, devicesAndroid) unless devicesAndroid.nil?
    if @message.save
      redirect_back fallback_location: messages_url, notice: 'Message accepté'
    else
      render :edit
    end
  end

  def reject
    authorize @message
    @message.approval_refused!

    # codes = [] <<  @message.author.code
    #
    # devicesIOS = Device.active.ios.by_codes(codes)
    # alert = "Message refusé: #{@message.title}"
    # send_ios_notifications(alert, devicesIOS) unless devicesIOS.nil?
    # devicesAndroid = Device.active.android.by_codes(codes)
    # build_android_notifications(@message, devicesAndroid) unless devicesAndroid.nil?

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

  def refresh_qr
    @message = Message.find_by_muuid(params[:muuid])
    students_names = @message.get_students_names_by_email(params[:email]) if params[:email].present?

    @transactionId = build_payconiq_transaction_id(@message)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message
      @message = Message.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def add_photo_params
      params.require(:message).permit(:photos => [])
    end


    def update_formdata_params
      params.require(:message).permit(:formdata)
    end

    def update_amount_to_pay_params
      params.require(:message).permit(:amount_to_pay, :billing_description, :billing_type, :account_id, :billing_comment, :billing_due_date, :billed_students, :include_payment, billed_students_attributes: [ :id, :student_id, :communication, :comment, :amount_to_pay ])
    end

    def message_params
      params.require(:message).permit(:title, :content, :school_id, :mtype, :when, :send_by_email, :send_to_app, :skip_send_by_email, :send_by_sms, :amount_to_pay, :status, :custom_author, :scheduled_datetime, "message_category_ids" => [])
    end

    # def set_s3_direct_post
    #   @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mfile_params
      params.require(:mfile).permit(:filename, :file_url, :school_id, :message_id)
    end

    def build_payconiq_transaction_id(message)
      access_token = message.account.payconiq_access_token
      transactionId = message.pq_create_transaction(message.amount_to_pay_cents, message.billing_description, access_token)
      logger.debug "$build_payconiq_transaction_id$ #{transactionId.inspect()} with description : #{message.billing_description}"
      return transactionId
    end

    def getTranslations(language_code, title, content, message_id, message_updated_at, school_id, translate)
      # get the translation for by message.id and params[:translate][:code]
      translation = Translation.where("message_id = ? and language_code = ? and school_id = ?", message_id, language_code, school_id).first_or_initialize
      if (translation.new_record? or translation.updated_at < message_updated_at)
        translation.title = translate.translate title, to: language_code
        translation.content = translate.translate content, to: language_code
        translation.message_id = message_id
        translation.language_code = language_code
        translation.school_id = school_id
        translation.save
        return translation.title, translation.content
      end
      
      return translation.title, translation.content

    end
end
