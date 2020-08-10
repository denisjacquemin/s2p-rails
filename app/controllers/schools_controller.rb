class SchoolsController < ApplicationController
  before_action :set_school, only: [:show, :update, :destroy]
  before_action :authenticate_user!
  before_action do
    helpers.authorize_current_school(current_user, current_school.id)
  end
  before_action :set_s3_direct_post, only: [:new, :edit]


  # GET /schools
  # GET /schools.json
  def index
    @schools = School.all
    authorize @schools
  end

  # GET /schools/1
  # GET /schools/1.json
  def show
    authorize @school
  end

  # GET /schools/new
  def new
    @school = School.new
    authorize @school
  end

  # GET /schools/1/edit
  def edit
    if params[:id].nil?
      @school = current_school
    else
      @school = School.find(params[:id])
    end

    authorize @school
    @school.accounts.new if @school.accounts.count == 0

  end

  # POST /schools
  # POST /schools.json
  def create
    @school = School.new(school_params)
    authorize @school
    respond_to do |format|
      if @school.save
        format.html { redirect_to edit_school_path(@school), notice: "L'école a été créé" }
        format.json { render :show, status: :created, location: @school }
      else
        format.html { render :new }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  def add_logo
    @school = School.find(params[:mfile][:school_id])
    @school.file_url = params[:mfile][:file_url]
    @school.save
  end

  # PATCH/PUT /schools/1
  # PATCH/PUT /schools/1.json
  def update
    authorize @school
    respond_to do |format|
      if @school.update(school_params)
        if current_user.admin?
          format.html { redirect_to edit_current_school_path, notice: "L'école a été mise à jour" }
        else
          format.html { redirect_to edit_school_path(@school), notice: "L'école a été mise à jour" }
        end

        format.json { render :show, status: :ok, location: @school }
      else
        format.html { render :edit }
        format.json { render json: @school.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /schools/1
  # DELETE /schools/1.json
  def destroy
    authorize @school
    @school.destroy
    respond_to do |format|
      format.html { redirect_to schools_url, notice: 'School was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def change_school
    session[:current_school]  = params[:selected_school_id]
    redirect_to root_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_school
      @school = School.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def school_params
      params.require(:school).permit(:name, :address, :phone, :email, :validation_workflow_active, :allow_translation, :url, :send_code_title_template, :send_code_template, :sms_provision, :message_month_limit, :message_day_limit, :activate_message_date_limit, :billing_enable, :payconiq_enable, :delete_students_on_csv_import, :acaweb, :is_ifapme, :bulletin_enable, :new_recipients_selection, :iscity, :auto_delete_messages, accounts_attributes: [:name, :payconiq_access_token, :account_number, :_destroy, :id])
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
