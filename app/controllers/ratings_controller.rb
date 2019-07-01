class RatingsController < ApplicationController
  before_action :set_rating, only: [:show, :edit, :update, :destroy]

  layout 'reports'

  # GET /ratings
  # GET /ratings.json
  def index
    # @levels = Student.where(school_id: @current_school.id).pluck(:level).uniq
    # @classrooms =  Student.where(school_id: @current_school.id).pluck(:classroom).uniq
    @groups = Group.only_level.by_school(current_school.id)
    @competencies = Competency.by_school(current_school.id)
    @current_group_selected_id = @groups&.first&.id
    @current_competency_selected_id = @competencies&.first&.id

    @periods = Period.by_school(current_school.id).ordered
    @current_year_selected_id = 1

    @students = Student.by_school(current_school.id).by_group(@current_group_selected_id)
  end

  def students
    @current_group_selected_id = params[:current_group_selected_id]
    @students = Student.by_school(current_school.id).by_group(@current_group_selected_id)
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_params
      params.require(:rating).permit(:student_id, :competency_id, :rating, :period, :comment)
    end
end
