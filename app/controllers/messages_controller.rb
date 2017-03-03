class MessagesController < ApplicationController
  before_action :authenticate_user!, except: [:show, :save_form]
  before_action :set_message, only: [:edit, :update, :publish, :unpublish, :send_for_approval, :accept, :reject, :update_groups, :destroy, :add_photo, :update_formdata, :export_formdata]
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
    @message = Message.find_by_muuid(params[:uuid])

    render layout: "show"
  end

  def save_form
    j = JSON.parse params[:message_form_formdata]
    j.prepend({value: 'horodateur', label: 'horodateur', value: I18n.l(Time.now.to_datetime().in_time_zone, format: :short)})
    @form = Form.new(muuid: params[:muuid], formdata: JSON.generate(j))

    @form.save
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
    @forms = Form.by_muuid(@message.muuid).latest_first.page params[:page]
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

  def add_photo
    if @message.update(add_photo_params)
      redirect_to edit_message_path(@message), notice: 'Le message a été mis à jour.'
    end
  end

  def update_formdata
    if @message.update(update_formdata_params)
      redirect_to edit_message_path(@message), notice: 'Le message a été mis à jour.'
    end
  end

  def export_formdata
    forms = Form.by_muuid(@message.muuid).latest_first
    rows = []
    column_names = Set.new
    forms.each do |form| # for each form get the colum names
      formjson = JSON.parse(form.formdata)
      formjson.each do |column|
        column_names.add(column['label'].strip) # if it does't exist yet add column name to columns_names Set
      end
    end

    rows = []

    forms.each do |form| # for each form build row
      formjson = JSON.parse(form.formdata)
      row = []
      column_names.each_with_index do |column_name, index|
        row[index] = ""
        formjson.each do |column|
          logger.info "current culumn_name: #{column_name} for column: #{column.inspect}"
          logger.info "#{column['label']} == #{column_name} = #{column['label'] == column_name}"
          if column['label'].strip == column_name
            if row[index] === ""
              row[index] = column['value']
            else
              row[index] += ', ' + column['value']
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

        send_data csv_data, filename: "export_#{filename_title}_#{I18n.l(Time.now, format: :short).parameterize}.csv"
      }
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    authorize @message
    case params[:status]
      when 'publish'
        @message.published!
    end

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

    def message_params
      params.require(:message).permit(:title, :content, :school_id, :mtype, :when, :send_by_email, :send_to_app, :skip_send_by_email, :status)
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mfile_params
      params.require(:mfile).permit(:filename, :file_url, :school_id, :message_id)
    end
end
