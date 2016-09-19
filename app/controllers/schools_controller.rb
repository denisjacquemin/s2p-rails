class SchoolsController < ApplicationController
  before_action :set_school, only: [:show, :update, :destroy]
  before_action :authenticate_user!

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
    @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    if params[:id].nil?
      @school = current_school
    else
      @school = School.find(params[:id])
    end
    authorize @school
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
    @school = current_school
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
      params.require(:school).permit(:name, :address, :phone, :email, :validation_workflow_active, :url)
    end
end
