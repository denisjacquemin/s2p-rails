class RatingsController < ApplicationController
  before_action :set_rating, only: [:show, :edit, :update, :destroy]

  # GET /ratings
  # GET /ratings.json
  def index

    authorize Rating

    # @levels = Student.where(school_id: @current_school.id).pluck(:level).uniq
    # @classrooms =  Student.where(school_id: @current_school.id).pluck(:classroom).uniq
    @groups = Group.only_level.by_school(current_school.id)
    @current_group_selected_id = @groups&.first&.id
    set_ratings
  end

  def students
    @current_group_selected_id = params[:current_group_selected_id]
    set_ratings
  end

  def by_student
    @groups = Group.only_level.by_school(current_school.id)
    @group_selected_id = @groups&.first&.id
    @students = Student.by_group(@group_selected_id)
    @student_selected_id = @students&.first&.id
    @student_ratings = {}
    set_ratings_for_one_students()
  end

  def change_group
    @group_selected_id = params[:group_selected_id]
    @students = Student.by_group(@group_selected_id)
    @student_selected_id = @students&.first&.id
    @student_ratings = {}
    set_ratings_for_one_students()
  end

  def change_student
    @group_selected_id = params[:group_selected_id]
    @student_selected_id = params[:student_selected_id]
    @student_ratings = {}
    set_ratings_for_one_students()
  end

  # GET /ratings/1
  # GET /ratings/1.json
  def show

  end

  # GET /ratings/new
  def new
    @rating = Rating.new
  end

  # GET /ratings/1/edit
  def edit
  end

  def save 
    current_group_selected_id = params[:current_group_selected_id]
    competency_id = params[:current_competency_selected_id]
    value = params[:value]
    student_id = params[:"s-id"]
    period_id = params[:"p-id"]

    rating = Rating.find_or_create_by(student_id: student_id, school_id: current_school.id, competency_id: competency_id, period_id: period_id)
    rating.rating = value
    rating.comment = params[:comment]
    rating.save

    @el_id = params[:el_id]
    @rating_comment = params[:comment]
  end

  def save_comment 
    current_group_selected_id = params[:current_group_selected_id]
    competency_id = params[:current_competency_selected_id]
    comment = params[:comment]
    student_id = params[:"s-id"]
    period_id = params[:"p-id"]

    rating = Rating.find_or_create_by(student_id: student_id, school_id: current_school.id, competency_id: competency_id, period_id: period_id)
    rating.comment = params[:comment]
    rating.save

    @el_id = params[:el_id]
    @rating_comment = params[:comment]
  end

  # POST /ratings
  # POST /ratings.json
  def create
    @rating = Rating.new(rating_params)

    respond_to do |format|
      if @rating.save
        format.html { redirect_to @rating, notice: 'Rating was successfully created.' }
        format.json { render :show, status: :created, location: @rating }
      else
        format.html { render :new }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /ratings/1
  # PATCH/PUT /ratings/1.json
  def update
    respond_to do |format|
      if @rating.update(rating_params)
        format.html { redirect_to @rating, notice: 'Rating was successfully updated.' }
        format.json { render :show, status: :ok, location: @rating }
      else
        format.html { render :edit }
        format.json { render json: @rating.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ratings/1
  # DELETE /ratings/1.json
  def destroy
    @rating.destroy
    respond_to do |format|
      format.html { redirect_to ratings_url, notice: 'Rating was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_rating
      @rating = Rating.find(params[:id])
    end

    def set_ratings
      @periods = Period.by_school(current_school.id).ordered
      @competencies = Group.find(@current_group_selected_id).competencies.ordered
      @competency_selected_id = params[:current_competency_selected_id] || @competencies&.first&.id&.to_s
      @students = Student.includes(:ratings).by_school(current_school.id).by_group(@current_group_selected_id)
      @ratings = {}
      @students.each{ |s| 
        student_ratings = {}
        s.ratings.each { |r|
          student_ratings[r.period_id] = {value: r.rating, comment: r.comment} if r.competency_id.to_s == @competency_selected_id
        }
        @ratings[s.id] = student_ratings
      }
    end

    def set_ratings_for_one_students()
      @current_student = Student.find @student_selected_id
      @current_student.ratings.each { |r|
        @student_ratings[r.competency_id] = Hash.new if @student_ratings[r.competency_id].nil?
        @student_ratings[r.competency_id][r.period_id] = {value: r.rating, comment: r.comment}
      }
    
      @periods = Period.by_school(current_school.id).ordered
      @competencies = Group.find(@group_selected_id).competencies.ordered
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_params
      params.require(:rating).permit(:student_id, :competency_id, :rating, :period, :comment)
    end
end
