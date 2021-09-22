class EvaluationsController < ApplicationController
  before_action :set_evaluation, only: [:show, :edit, :update, :destroy]

  # GET /evaluations
  # GET /evaluations.json
  def index
    if current_user.admin? or current_user.superadmin?
      @groups = Group.where(school_id: current_school.id).valid_class
    else
      @groups = Group.where(school_id: current_school.id, id: current_user.report_allowed_group_ids).valid_class
    end
  end

  def change_group
    @group_selected_id = params[:group_selected_id]
    @periods = Group.find(@group_selected_id).periods.without_weights.ordered
  end

  def change_period
    @period_selected_id = params[:period_selected_id]
    @group_selected_id = params[:group_selected_id]

    # get all competencies fro this group
    group_competency_ids = Competency.where(school_id: current_school.id, group_id: @group_selected_id).pluck(:id)
    # get all report_competency_users for having group_competency_ids and current_user.id
    report_competency_users = ReportCompetencyUser.where(competency_id: group_competency_ids, user_id: current_user.id)
    # remove from group_competency_ids all report_competency_users with allowed=false 
    report_competency_users.each do |rcu|
      group_competency_ids.delete(rcu.competency_id) unless rcu.allowed
    end
    @competencies = Competency.by_school(current_school.id).where(id: group_competency_ids).distinct.ordered
  end

  def change_competency
    @group_selected_id = params[:group_selected_id]
    @period_selected_id = params[:period_selected_id]
    @competency_selected_id = params[:competency_selected_id]
    set_evaluation_table_data(@group_selected_id, @competency_selected_id, @period_selected_id)
  end

  def load_averages
    @group_selected_id = params[:group_selected_id]
    @period_selected_id = params[:period_selected_id]
    @competency_selected_id = params[:competency_selected_id]
    @competency_weight = Competency.select(:weight).find(@competency_selected_id).weight
    set_evaluation_table_data(@group_selected_id, @competency_selected_id, @period_selected_id)
    set_ratings_for_averages(@group_selected_id, @competency_selected_id, @period_selected_id, @students)

  end

  def save_average_comment
    group_selected_id = params[:group_selected_id]
    period_selected_id = params[:period_selected_id]
    competency_selected_id = params[:competency_selected_id]
    student_id = params[:"s-id"]
    comment = params[:"comment"]
    current_rating_year = RatingYear.by_school(current_school.id)&.first

    Rating.where(
      school_id: current_school.id, 
      student_id: student_id, 
      competency_id: competency_selected_id, 
      period_id: period_selected_id,
      # rating_year_id: current_rating_year
    ).update_all(comment: comment)
  end


  def set_evaluation_table_data(group_id, competency_id, period_id)
    group_selected = Group.find group_id
    @students = Student.by_school(current_school.id).by_group(group_id).where(level: group_selected.name).order(:lastname, :firstname)
    @evaluations = Evaluation.where(school_id: current_school.id, competency_id: competency_id, period_id: period_id).order("date ASC")
    
    @quotations = {}
    # for each evaluations
    @evaluations.each do |evaluation|
      # get the quotations for a given evaluation.id 
      quotations_by_evaluation = Quotation.where(school_id: current_school.id, evaluation_id: evaluation.id)
      
      evaluations_by_students = {}
      quotations_by_evaluation.each do |quot|
         evaluations_by_students[:"#{quot.student_id}"] = { id: quot.id, value: quot.value, averageable: quot.averageable, comment: quot.comment } 
      end
      @quotations[:"#{evaluation.id}"] = evaluations_by_students
    end
  end

  def set_ratings_for_averages(group_id, competency_id, period_id, students)
    #current_rating_year = RatingYear.by_school(current_school.id)&.first
    ratings = Rating.where(school_id: current_school.id, period_id: period_id, student_id: students.pluck(:id), competency_id: competency_id)
    @ratings_by_students = {}

    ratings.each do |rating|
      @ratings_by_students[:"#{rating.student_id}"] = { average: rating.average, comment: rating.comment } 
   end

  end

  def save_quot
    evaluation_id = params[:"e-id"]
    student_id = params[:"s-id"]
    competency_id = params[:"c-id"]
    period_id = params[:"p-id"]
    group_id = params[:"g-id"]
    averageable = params[:averageable]
    value = params[:value]
    comment = params[:comment]
    averageable = params[:averageable]

    quot = Quotation.find_or_create_by(
      student_id: student_id, 
      school_id: current_school.id, 
      evaluation_id: evaluation_id,
      competency_id: competency_id)

    old_value = quot.value
    new_value = params[:value]
    old_averageable = quot.averageable
    new_averageable = params[:averageable]

    current_rating_year = RatingYear.by_school(current_school.id)&.first
 

    quot.averageable = averageable
    quot.value = value
    quot.comment = comment
    puts quot.inspect
    quot.save
    

    # compute average if averageable has changed or if quotation value has changed
    if ((old_averageable != new_averageable) or (!quot.value.nil? && !quot.value&.empty? && old_value != new_value))
      Rating.computeAverage(competency_id, current_school.id, group_id, period_id, student_id)
    end
  end

  def isAValidFloat(stringToTest)
    /\d+[,.]?\d*/ === stringToTest
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
    @period_selected_id = @evaluation.period_id

    respond_to do |format|
      if @evaluation.save
        set_evaluation_table_data(@evaluation.group_id, @competency_selected_id, @period_selected_id)


        format.html { redirect_to @evaluation, notice: 'Evaluation was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @evaluation }
      else
        @period_id = @evaluation.period_id
        @competency_id = @evaluation.competency_id
        format.html { render :new }
        format.js { render :create, evaluation: @evaluation }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /evaluations/1
  # PATCH/PUT /evaluations/1.json
  def update
    Rating.computeAverage(@evaluation.competency_id, current_school.id, @evaluation.group_id, @evaluation.period_id, student_id)

    respond_to do |format|
      if @evaluation.update(evaluation_params)
        @competency_selected_id = @evaluation.competency_id
        @period_selected_id = @evaluation.period_id
        set_evaluation_table_data(@evaluation.group_id, @evaluation.competency_id, @period_selected_id)

        format.html { redirect_to @evaluation, notice: 'Evaluation was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @evaluation }
      else
        @period_id = @evaluation.period_id
        @competency_id = @evaluation.competency_id
        format.html { render :edit }
        format.js { render :edit, evaluation: @evaluation }
        format.json { render json: @evaluation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /evaluations/1
  # DELETE /evaluations/1.json
  def destroy
    @evaluation.destroy
    respond_to do |format|
      set_evaluation_table_data(@evaluation.group_id, @evaluation.competency_id, @evaluation.period_id)

      format.html { redirect_to evaluations_url, notice: 'Evaluation was successfully destroyed.' }
      format.js
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
      params.require(:evaluation).permit(:description, :weight, :competency_id, :period_id, :date)
    end
end