class RatingsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rating, only: [:show, :edit, :update, :destroy]

  # GET /ratings
  # GET /ratings.json
  def index

    authorize Rating

    # @levels = Student.where(school_id: @current_school.id).pluck(:level).uniq
    # @classrooms =  Student.where(school_id: @current_school.id).pluck(:classroom).uniq
    @rating_years = RatingYear.by_school(current_school.id).ordered

    # default behaviour, most of the time only one RatingYear for the school
    # allow a school to define multiple Rating Year ie: "2019-2020" and "2019-2020 / 2020-2021"
    @current_rating_year = RatingYear.by_school(current_school.id)&.first
    # @current_rating_year = RatingYear.by_school(current_school.id).includes(:rating_year_groups).where("rating_year_groups.group_id" => @current_group_selected_id)&.first if @current_rating_year.nil?

    @groups = @current_rating_year&.filtered_groups
    # @current_group_selected_id = @groups&.first&.id

  end

  def students
    @current_rating_year = params[:current_selected_rating_year]
    @current_group_selected_id = params[:current_group_selected_id]
    @current_competency_selected_id = params[:current_competency_selected_id]
    # @current_rating_year = RatingYear.by_school(current_school.id).includes(:rating_year_groups).where("rating_year_groups.group_id" => @current_group_selected_id)&.first if @current_rating_year.nil?
    @current_competency = Competency.find @current_competency_selected_id 
    set_ratings unless @current_competency.title_only
  end


  # initialize by_student screen, no default student selected therefore no ratings to display
  def by_student
    @groups = Group.only_level.by_school(current_school.id)
    @group_selected_id = getCurrentGroup(params, @groups)
    @students = Student.by_group(@group_selected_id).order('lastname ASC, firstname ASC') 
    # default behaviour, most of the time only one RatingYear for the school
    # allow a school to define multiple Rating Year ie: "2019-2020" and "2019-2020 / 2020-2021"
    
    @current_rating_year = getCurrentRatingYear(params)
  end

  def change_year
    @rating_years = RatingYear.by_school(current_school.id).ordered
    @current_selected_rating_year_id = params[:current_selected_rating_year]
    @current_rating_year = RatingYear.find(@current_selected_rating_year_id)

    @groups = @current_rating_year&.filtered_groups
  end


  # change the current group and reload list of students
  def change_group
    @group_selected_id = getCurrentGroup(params, @groups)
    @students = Student.by_group(@group_selected_id).order(:lastname)
  end

  def change_student
    @group_selected_id = getCurrentGroup(params, @groups)
    @student_selected_id = params[:student_selected_id]
    @student_ratings = {}
    @current_rating_year = getCurrentRatingYear(params)
    set_comments_for_one_student(@current_rating_year.id) unless @student_selected_id.blank?
    set_ratings_for_one_students(@current_rating_year.id) unless @student_selected_id.blank?
  end

  def choose_report_period
    @periods = Period.by_school(current_school.id).without_weights.ordered
    respond_to do |format|
      format.html 
      format.js
    end
  end

  def reports_to_pdf
    params[:student][:id]
    params[:period]

    @school = current_school
    @period_selected  = Period.find params[:period]

    combined_pdfs = CombinePDF.new

    params[:student][:id].map do |student_id| 

      @current_student = Student.find student_id
      @student_ratings = {}
      
      # todo add year_id to select comment
      @period_comment = RatingComment.where(student_id: student_id, school_id: @school.id, period_id: @period_selected.id).first
      @current_student.ratings.each { |r| # todo add year_id to select ratings
        @student_ratings[r.competency_id] = Hash.new if @student_ratings[r.competency_id].nil?
        @student_ratings[r.competency_id][r.period_id] = {value: r.rating, comment: r.comment}
      }

      @periods = Period.by_school(current_school.id).ordered

      student_s_group_id = Group.where('lower(name) = ? and school_id = ?', @current_student&.level&.downcase, @current_student.school_id).pluck(:id).first
      
      @competencies = Group.find(student_s_group_id).filtered_competencies
      {
        current_student: @current_student,
        student_ratings: @student_ratings,
        periods: @periods,
        competencies: @competencies,
        period_comment: @period_comment
      }      

      pdf_data = render_to_string_with_wicked_pdf pdf: "",
      page_size: 'A4',
      template: "/ratings/reports_pdf.html.erb",
      header:  {   
        spacing: 20,
        html: {            
          template: '/ratings/report_pdf_header.html.erb'
        }
      },
      margin: {   
        top:               30,                     # default 10 (mm)
        bottom:            30,
        left:              10,
        right:             10 
      },
      layout: "report_pdf.html",
      orientation: "Portrait",
      zoom: 1,
      dpi: 72,
      encoding: "UTF-8"      
      combined_pdfs << CombinePDF.parse(pdf_data)
    end
    
    send_data combined_pdfs.to_pdf, filename: "bulletins_#{Date.today}", type: "application/pdf"
  end

  def report_to_pdf

    @student_selected_id = params[:selected_student_id]
    @group_selected_id = params[:selected_group_id]
    @group = Group.find @group_selected_id
    @period_selected = Period.find params[:selected_period_id]

    set_ratings_for_one_students()

    @school = @current_student.school

    respond_to do |format|
      format.pdf do
          render pdf: "bulletin_milo_jacquemin_#{Date.today}",
          viewport_size: '1280x1024',
          page_size: 'A4',
          template: "/ratings/report_pdf.html.erb",
          header:  {   
            spacing: 30,
            html: {            
              template: '/ratings/report_pdf_header.html.erb',          # use :template OR :url
              # layout:   'pdf_plain',             # optional, use 'pdf_plain' for a pdf_plain.html.pdf.erb file, defaults to main layout
              url:      'www.example.com',
              locals:   { foo: @bar }
            }
          },
          margin: {   
            top:               40,                     # default 10 (mm)
            bottom:            30,
            left:              10,
            right:             10 
          },
          layout: "report_pdf.html",
          orientation: "Portrait",
          lowquality: true,
          zoom: 1,
          dpi: 75,
          encoding: "UTF-8",
          show_as_html: params.key?('debug')
      end
    end
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
    rating_year_id = params[:"ry-id"]
    rating = Rating.find_or_create_by(student_id: student_id, school_id: current_school.id, competency_id: competency_id, period_id: period_id, rating_year_id: rating_year_id)
    
    rating.rating = value
    rating.save

    @el_id = params[:el_id]
    @rating_comment = params[:comment]
  end

  def edit_comment
    @rating = Rating.find_or_create_by(student_id: params[:student_id], school_id: current_school.id, competency_id: params[:competency_id], period_id: params[:period_id])
    respond_to do |format|
      format.js
    end
  end

  def edit_period_comment 
    @period_comment = RatingComment.find_or_create_by(student_id: params[:student_id], school_id: current_school.id, period_id: params[:period_id], year_id: params[:year_id])
    respond_to do |format|
      format.js
    end
  end

  def save_comment 
    rating = Rating.find_or_create_by(student_id: params[:rating][:student_id], school_id: current_school.id, competency_id: params[:rating][:competency_id], period_id: params[:rating][:period_id])
    rating.comment = params[:rating][:comment]
    rating.save
  end

  def save_period_comment 
    rating_comment = RatingComment.find_or_create_by(student_id: params[:rating_comment][:student_id], school_id: current_school.id, period_id: params[:rating_comment][:period_id], year_id: params[:rating_comment][:year_id])
    rating_comment.content = params[:rating_comment][:content]
    rating_comment.save
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

    def getCurrentGroup(params, groups)
      if params[:group_selected_id].present?
        return params[:group_selected_id]
      else
        return groups&.first&.id
      end
    end 

    def getCurrentRatingYear(params)
      if params[:selected_current_rating_year].present?
        RatingYear.find params[:selected_current_rating_year]
      else
        current_rating_year = RatingYear.by_school(current_school.id).where('all_groups = true')&.first
        current_rating_year = RatingYear.by_school(current_school.id).includes(:rating_year_groups).where("rating_year_groups.group_id" => @group_selected_id)&.first if current_rating_year.nil?
        return current_rating_year
      end
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_rating
      @rating = Rating.find(params[:id])
    end

    def set_ratings
      @periods = Period.by_school(current_school.id).ordered
        # @competencies = Group.find(@current_group_selected_id).competencies.ordered
      # @competency_selected_id = @current_competency_selected_id
      @students = Student.includes(:ratings).by_school(current_school.id).by_group(@current_group_selected_id)
      @ratings = {}
      @student_ratings = {}
      @students.each{ |student| 
        student_ratings = {}
        student.ratings.by_rating_year(@current_rating_year).each { |r|
          student_ratings[r.period_id] = {value: r.rating, comment: r.comment} if r.competency_id.to_s == @current_competency_selected_id
        }
        @ratings[student.id] = student_ratings
      }
    end

    def set_comments_for_one_student(year_id)
      @current_student = Student.find @student_selected_id
      @student_comments = {}
      @current_student.rating_comments.by_rating_year(year_id).each { |c| 
        @student_comments[c.period_id] = { content: c.content}
      }
    end

    def set_ratings_for_one_students(year_id)
      @current_student = Student.find @student_selected_id
      @student_ratings = {}
      @current_student.ratings.by_rating_year(year_id).each { |r|
        @student_ratings[r.competency_id] = Hash.new if @student_ratings[r.competency_id].nil?
        @student_ratings[r.competency_id][r.period_id] = {value: r.rating, comment: r.comment}
      }

      @periods = Period.by_school(current_school.id).ordered
      @competencies = Group.find(@group_selected_id).filtered_competencies
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_params
      params.require(:rating).permit(:student_id, :competency_id, :rating, :period, :comment)
    end
end
