class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:show, :edit, :update, :destroy]

  # GET /evaluations
  # GET /evaluations.json
  def index
    @groups = Group.where(school_id: current_school.id).only_level
  end

  def change_group
    @group_selected_id = params[:group_selected_id]
    @periods = Group.find(@group_selected_id).periods.without_weights.ordered
  end

  def change_period
    @period_selected_id = params[:period_selected_id]
    @group_selected_id = params[:group_selected_id]
    @competencies = Competency.joins(:periods).by_school(current_school.id).where(group_id: @group_selected_id).distinct.ordered
  end

  def change_competency
    @group_selected_id = params[:group_selected_id]
    @period_selected_id = params[:period_selected_id]
    @competency_selected_id = params[:competency_selected_id]

    @evaluations = Evaluation.where(school_id: current_school.id, competency_id: @competency_selected_id)
    @students = Student.by_school(current_school.id).by_group(@group_selected_id).order('lastname ASC, firstname ASC')
    
    @quotations = {}
    # for each evaluations
    @evaluations.each do |evaluation|
      # get the quotations for a given evaluation.id 
      quotations_by_evaluation = Quotation.where(school_id: current_school.id, evaluation_id: evaluation.id)
      
      evaluations_by_students = {}
      quotations_by_evaluation.each do |quot|
         evaluations_by_students[:"#{quot.student_id}"] = { id: quot.id, value: quot.value, averageable: quot.averageable } 
      end
      @quotations[:"#{evaluation.id}"] = evaluations_by_students
    end
  end

  def save_quot
    evaluation_id = params[:"e-id"]
    student_id = params[:"s-id"]
    averageable = params[:averageable]
    value = params[:value]

    quot = Quotation.find_or_create_by(
      student_id: student_id, 
      school_id: current_school.id, 
      evaluation_id: evaluation_id)

    quot.averageable = averageable
    quot.value = value
    quot.save

  end

  # GET /evaluations/1
  # GET /evaluations/1.json
  def show
  end

  # GET /evaluations/new
  def new
    @evaluation = Evaluation.new
    @period_id = params[:pid]
    @competency_id = params[:cid]

    respond_to do |format|
      format.html 
      format.js
    end
    
  end

  # GET /evaluations/1/edit
  def edit
  end

  # POST /evaluations
  # POST /evaluations.json
  def create
    @evaluation = Evaluation.new(evaluation_params)
    @evaluation.school_id = current_school.id
    @evaluation.group_id = Competency.select(:group_id).find(@evaluation.competency_id)&.group_id
    @competency_selected_id = @evaluation.competency_id
    byebug
    respond_to do |format|
      if @evaluation.save
        @evaluations = Evaluation.where(school_id: current_school.id, competency_id: @competency_selected_id)
        @students = Student.by_school(current_school.id).by_group(@evaluation.group_id).order('lastname ASC, firstname ASC')
    
        format.html { redirect_to @evaluation, notice: 'Evaluation was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @evaluation }
      else
        format.html { render :new }
        format.js { render :errors, competency: @evaluation }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /evaluations/1
  # PATCH/PUT /evaluations/1.json
  def update
    respond_to do |format|
      if @evaluation.update(evaluation_params)
        format.html { redirect_to @evaluation, notice: 'Evaluation was successfully updated.' }
        format.json { render :show, status: :ok, location: @evaluation }
      else
        format.html { render :edit }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluations/1
  # DELETE /evaluations/1.json
  def destroy
    @evaluation.destroy
    respond_to do |format|
      format.html { redirect_to evaluations_url, notice: 'Evaluation was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def evaluation_params
      params.require(:evaluation).permit(:description, :weight, :competency_id, :period_id)
    end
end
