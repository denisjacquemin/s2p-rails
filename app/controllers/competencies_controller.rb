class CompetenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_competency, only: [:show, :edit, :update, :destroy, :edit_competency_writer_accesses]


  # GET /competencies
  # GET /competencies.json
  def index
    @competencies = Competency.where(school_id: current_school.id).ordered
    @periods = Period.by_school(current_school.id).ordered
    @rating_years = RatingYear.by_school(current_school.id).ordered
    @rating_comments = RatingComment.by_school(current_school.id).ordered
  end

  def init
    current_school.competencies.map(&:delete) # soft delete every competencies

    Competency.create(name: 'MATHÉMATIQUES', school_id: current_school.id, level: 1, title_only: true, all_periods: true, all_groups: true, order: 1)
    Competency.create(name: 'Résolution de problèmes', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 2)
    Competency.create(name: 'Nombres et opérations', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 3)
    Competency.create(name: 'Grandeurs', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 4)
    Competency.create(name: 'Figures et solides', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 5)

    Competency.create(name: 'LANGUE FRANÇAISE', school_id: current_school.id, level: 1, title_only: true, all_periods: true, all_groups: true, order: 6)
    Competency.create(name: 'Savoir-écouter - savoir-parler', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 7)
    Competency.create(name: 'Savoir-lire', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 8)
    Competency.create(name: 'Savoir-écrire', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 9)
    Competency.create(name: 'Analyse grammaticale', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 10)
    Competency.create(name: 'Orthographe', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 11)
    Competency.create(name: 'Conjugaison', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 12)
    Competency.create(name: 'Vocabulaire', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 13)

    Competency.create(name: 'Éducation Artistique', school_id: current_school.id, level: 1, title_only: false, all_periods: true, all_groups: true, order: 14)
    
    Competency.create(name: 'LANGUES MODERNES', school_id: current_school.id, level: 1, title_only: true, all_periods: true, all_groups: true, order: 15)

    Competency.create(name: 'Éducation par la technologie', school_id: current_school.id, level: 1, title_only: false, all_periods: true, all_groups: true, order: 16)

    Competency.create(name: 'Éducation aux médias', school_id: current_school.id, level: 1, title_only: false, all_periods: true, all_groups: true, order: 17)

    Competency.create(name: 'Éducation physique', school_id: current_school.id, level: 1, title_only: false, all_periods: true, all_groups: true, order: 18)

    redirect_to competencies_url
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
    @competency.periods = Period.by_school(current_school.id)
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
    @competency.order = Competency.where(school_id: current_school.id).count + 1


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
    @competency.delete
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
      params.require(:competency).permit(:name, :level, :order, :comment, :title_only, :is_totals, :all_periods, :all_groups, group_ids: [], period_ids: [] )
    end
end
