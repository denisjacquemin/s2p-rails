class CompetenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_competency, only: [:show, :edit, :update, :destroy, :edit_competency_writer_accesses]

  layout 'reports'

  # GET /competencies
  # GET /competencies.json
  def index
    @competencies = Competency.where(school_id: current_school.id).order(:order)
  end

  def writers_access
    @users = User.where('? = ANY (schools)', current_school.id).order(lastname: :asc).no_superadmin.active
    @user_selected_id = params[:selected_user] || @users&.first&.id
    # @competency_write_accesses = CompetencyWriterAccess.where(user_id: @user_selected_id, school_id: current_school.id)
    @competencies = Competency.where(school_id: current_school.id).order(:order)
    render layout: false
  end

  # GET /competencies/1
  # GET /competencies/1.json
  def show
  end

  # GET /competencies/new
  def new
    @competency = Competency.new
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # GET /competencies/1/edit
  def edit
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # POST /competencies
  # POST /competencies.json
  def create
    @competency = Competency.new(competency_params)
    @competency.school_id = current_school.id
    @competency.order = 0


    respond_to do |format|
      if @competency.save
        @competencies = Competency.where(school_id: current_school.id).order(:order)
        format.html { redirect_to @competency, notice: 'Competency was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @competency }
      else
        format.html { render :new }
        format.js { render :errors, competency: @competency }
        format.json { render json: @competency.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /competencies/1
  # PATCH/PUT /competencies/1.json
  def update
    respond_to do |format|
      if @competency.update(competency_params)
        @competencies = Competency.where(school_id: current_school.id).order(:order)
        format.html { redirect_to @competency, notice: 'Competency was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @competency }
      else
        format.html { render :edit }
        format.json { render json: @competency.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_orders
    competencies = {}
    params[:orders].each_with_index do |c, index|
      competencies[c] = {order: index} 
    end
    Competency.update(competencies.keys, competencies.values)
    head :ok, content_type: "text/html"
  end

  # DELETE /competencies/1
  # DELETE /competencies/1.json
  def destroy
    @competency.destroy
    respond_to do |format|
      format.html { redirect_to competencies_url, notice: 'Competency was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_competency
      @competency = Competency.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def competency_params
      params.require(:competency).permit(:name, :level, :comment, group_ids: [] )
    end
end
