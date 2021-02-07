class CompetenciesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_competency, only: [:show, :edit, :update, :destroy, :edit_competency_writer_accesses]


  # GET /competencies
  # GET /competencies.json
  def index
    
    @periods = Period.by_school(current_school.id).ordered
    @rating_years = RatingYear.by_school(current_school.id).ordered
    @rating_comments = RatingComment.by_school(current_school.id).ordered
    @groups = Group.where(school_id: current_school.id).only_level
    @selected_group = @groups.first.id
    @competencies = Competency.where(school_id: current_school.id, group_id: @selected_group).ordered
  end

  def init
    current_school.competencies.map(&:delete) # soft delete every competencies

    Period.create(school_id: current_school.id, name: 'Max', order: 0, is_weight: true)
    Period.create(school_id: current_school.id, name: 'P1', order: 1)
    Period.create(school_id: current_school.id, name: 'P2', order: 2)
    Period.create(school_id: current_school.id, name: 'P3', order: 3)

    @groups = Group.where(school_id: current_school.id).only_level
    @groups.each do |group|
      Competency.create(name: 'MATHÉMATIQUES', school_id: current_school.id, level: 1, title_only: true, all_periods: true, order: 1, group_id: group.id)
      Competency.create(name: 'Résolution de problèmes', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 2, group_id: group.id)
      Competency.create(name: 'Nombres et opérations', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 3, group_id: group.id)
      Competency.create(name: 'Grandeurs', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 4, group_id: group.id)
      Competency.create(name: 'Figures et solides', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 5, group_id: group.id)
      Competency.create(name: 'Total', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 6, is_totals: true, group_id: group.id)


      Competency.create(name: 'LANGUE FRANÇAISE', school_id: current_school.id, level: 1, title_only: true, all_periods: true, order: 7, group_id: group.id)
      Competency.create(name: 'Savoir-écouter - savoir-parler', school_id: current_school.id, level: 2, title_only: false, all_periods: true, all_groups: true, order: 8, group_id: group.id)
      Competency.create(name: 'Savoir-lire', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 9, group_id: group.id)
      Competency.create(name: 'Savoir-écrire', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 10, group_id: group.id)
      Competency.create(name: 'Analyse grammaticale', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 11, group_id: group.id)
      Competency.create(name: 'Orthographe', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 12, group_id: group.id)
      Competency.create(name: 'Conjugaison', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 13, group_id: group.id)
      Competency.create(name: 'Vocabulaire', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 14, group_id: group.id)
      Competency.create(name: 'Total', school_id: current_school.id, level: 2, title_only: false, all_periods: true, order: 15, is_totals: true, group_id: group.id)


      Competency.create(name: 'Éducation Artistique', school_id: current_school.id, level: 1, title_only: false, all_periods: true, order: 16, group_id: group.id)
      
      Competency.create(name: 'LANGUES MODERNES', school_id: current_school.id, level: 1, title_only: false, all_periods: true, order: 17, group_id: group.id)

      Competency.create(name: 'Éducation par la technologie', school_id: current_school.id, level: 1, title_only: false, all_periods: true, order: 18, group_id: group.id)

      Competency.create(name: 'Éducation aux médias', school_id: current_school.id, level: 1, title_only: false, all_periods: true, order: 19, group_id: group.id)

      Competency.create(name: 'Éducation physique', school_id: current_school.id, level: 1, title_only: false, all_periods: true, order: 20, group_id: group.id)

    end
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
    @groups = Group.where(school_id: current_school.id).only_level
    @periods = Period.by_school(current_school.id)
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # GET /competencies/1/edit
  def edit
    @periods = Period.by_school(current_school.id)

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

    

    # for each group_id creates a competency
    competencies_to_create = []
    params[:competency][:group_ids].each do |group_id|
      competencies_to_create.push( { 
        name: params[:competency][:name], 
        level: params[:competency][:level], 
        title_only: params[:competency][:title_only], 
        is_totals: params[:competency][:is_totals], 
        all_groups: params[:competency][:all_groups],
        group_id: group_id,
        all_periods: params[:competency][:all_periods],
        period_ids: params[:competency][:period_ids],
        school_id: current_school.id,
        order: Competency.where(school_id: current_school.id, group_id: group_id).count + 1
      })
    end 
      

    respond_to do |format|
      if Competency.create(competencies_to_create)
        @groups = Group.where(school_id: current_school.id).only_level
        @selected_group = @groups.first.id
        @competencies = Competency.where(school_id: current_school.id, group_id: @selected_group).ordered
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
        @groups = Group.where(school_id: current_school.id).only_level
        @selected_group = @groups.first.id
        @competencies = Competency.where(school_id: current_school.id, group_id: @selected_group).ordered        
        
        format.html { redirect_to @competency, notice: 'Competency was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @competency }
      else
        format.html { render :edit }
        format.json { render json: @competency.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_competencies
    @groups = Group.where(school_id: current_school.id).only_level
    @selected_group = params[:selected_group_id]
    @competencies = Competency.where(school_id: current_school.id, group_id: @selected_group).ordered        
        
    respond_to do |format|
      format.js
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
