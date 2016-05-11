class MessagesController < ApplicationController
  include ActionView::Helpers::TextHelper # for truncate
  before_action :authenticate_user!
  before_action :set_message, only: [:show, :edit, :update, :publish, :unpublish, :send_for_approval, :accept, :reject, :update_groups, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  # GET /messages
  # GET /messages.json
  def index
    @messages = policy_scope(Message).order(created_at: :desc)
    authorize @messages
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
    authorize @message
  end

  # GET /messages/new
  def new
    @message = Message.new
    @mfile = Mfile.new
    authorize @message
  end

  # GET /messages/1/edit
  def edit
    @mfile = Mfile.new
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)
    authorize @message

    @message.author = current_user

    unless current_user.superadmin?
      @message.school_id = current_user.school_id
    end

    respond_to do |format|
      if @message.save
        format.html { redirect_to edit_message_path(@message), notice: 'Message was successfully created.' }
        format.json { render :show, status: :created, location: @message }
      else
        format.html { render :new }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /messages/1
  # PATCH/PUT /messages/1.json
  def update
    authorize @message
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to edit_message_path(@message), notice: 'Le message a été mis à jour.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_groups
    authorize @message
    # before update, compares the actual groups for the message against the submitted list
    actual_groups_ids = @message.groups
    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    submitted_groups_ids = [] if submitted_groups_ids.nil?

    # get the ids to be removed (remove_groups)
    actual_groups_to_delete = actual_groups_ids - submitted_groups_ids.map(&:to_i)

    # check if submited groups are not yet in db
    submitted_groups_to_add = submitted_groups_ids.select { |g| !actual_groups_ids.include?(g.to_i) }

    Message.add_groups(@message.id, submitted_groups_to_add.map(&:to_i)) if submitted_groups_to_add.any?
    Message.remove_groups(@message.id, actual_groups_to_delete) if actual_groups_to_delete.any?
    redirect_to edit_message_path(@message, t: 'groups'), notice: 'Le message a été mis à jour.'
  end

  def publish
    authorize @message
    @message.published!
    if @message.update(publish_date: DateTime.now)
      groups = @messages.groups
      students = Student.by_group_id(groups)
      student_codes = students.map {|s| s.code }
      devices = Device.by_codes(student_codes)

      devices.each { |device|
        n = Rpush::Apns::Notification.new
        n.app = Rpush::Apns::App.find_by_name("ios_app")
        n.device_token = device # 64-character hex string
        n.alert = @message.title
        n.data = {
          "title": truncate(@message.title, :length => 200),
          "body": truncate(@message.content, :length => 200),
          "badge": 1
        }
        n.save!
      }


      redirect_to messages_url, notice: 'Message publié avec succès'
    else
      render :edit
    end
  end

  def unpublish
    authorize @message
    @message.draft!
    if @message.update(publish_date: nil)
      redirect_to messages_url, notice: 'Message dépublié avec succès'
    else
      render :edit
    end
  end

  def send_for_approval
    authorize @message
    @message.waiting_for_approval!
    if @message.save
      redirect_to messages_url, notice: 'Message envoyé pour approbation avec succès'
    else
      render :edit
    end
  end

  def accept
    authorize @message
    @message.approval_accepted!
    if @message.save
      redirect_to messages_url, notice: 'Message accepté'
    else
      render :edit
    end
  end

  def reject
    authorize @message
    @message.approval_refused!
    if @message.save
      redirect_to messages_url, notice: 'Message refusé'
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
      format.html { redirect_to messages_url, notice: 'Message was successfully destroyed.' }
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
      params.require(:message).permit(:title, :content, :school_id)
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mfile_params
      params.require(:mfile).permit(:filename, :file_url, :school_id, :message_id)
    end
end
