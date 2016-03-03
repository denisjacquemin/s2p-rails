class MessagesController < ApplicationController
  before_action :set_message, only: [:show, :edit, :update, :update_groups, :destroy]

  # GET /messages
  # GET /messages.json
  def index
    @messages = Message.all
  end

  # GET /messages/1
  # GET /messages/1.json
  def show
  end

  # GET /messages/new
  def new
    @message = Message.new
  end

  # GET /messages/1/edit
  def edit
  end

  # POST /messages
  # POST /messages.json
  def create
    @message = Message.new(message_params)

    if current_user.admin?
      @student.school_id = current_user.school_id
    end

    respond_to do |format|
      if @message.save
        format.html { redirect_to @message, notice: 'Message was successfully created.' }
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
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to @message, notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
      else
        format.html { render :edit }
        format.json { render json: @message.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_groups
    # before update, compares the actual groups for the message against the submitted list
    actual_groups_ids = @message.groups
    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    submitted_groups_ids = [] if submitted_groups_ids.nil?

    actual_groups_to_delete = actual_groups_ids - submitted_groups_ids.map(&:to_i)

    Message.add_groups(@message.id, submitted_groups_ids.map(&:to_i)) if submitted_groups_ids.any?
    Message.remove_groups(@message.id, actual_groups_to_delete) if actual_groups_to_delete.any?
    redirect_to messages_url, notice: 'Message was successfully updated.'
  end

  # DELETE /messages/1
  # DELETE /messages/1.json
  def destroy
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
end
