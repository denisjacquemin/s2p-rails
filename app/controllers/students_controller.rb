class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :update_groups, :destroy]

  # GET /students
  # GET /students.json
  def index
    @students = policy_scope(Student).where(school_id: session[:current_school])
    authorize @students
  end

  # GET /students/1
  # GET /students/1.json
  def show
    authorize @student
  end

  # GET /students/new
  def new
    @student = Student.new
    authorize @student
  end

  # GET /students/1/edit
  def edit
    authorize @student
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)
    authorize @student

    if current_user.admin?
      @student.school_id = current_school
    end

    if @student.save
      redirect_to students_path, notice: t('controller.student.create.notice.success')
    else
      render :new
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    authorize @student
    respond_to do |format|
      if @student.update(student_params)
        format.html { redirect_to edit_student_path(@student), notice: t('controller.students.update.notice.success') }
        format.json { render :show, status: :ok, location: @student }
      else
        format.html { render :edit }
        format.json { render json: @student.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_groups
    authorize @student
    # before update, compares the actual groups for the student against the submitted list
    actual_groups_ids = @student.groups_obj.pluck(:id)
    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    submitted_groups_ids = [] if submitted_groups_ids.nil?

    actual_groups_to_delete = actual_groups_ids - submitted_groups_ids.map(&:to_i)

    # check if submited groups are not yet in db
    submitted_groups_to_add = submitted_groups_ids.select { |g| !actual_groups_ids.include?(g.to_i) }


    Student.add_groups(@student.id, submitted_groups_to_add.map(&:to_i)) if submitted_groups_to_add.any?
    Student.remove_groups(@student.id, actual_groups_to_delete) if actual_groups_to_delete.any?
    redirect_to edit_student_path(@student), notice: t('controller.students.update.notice.success')
  end

  # DELETE /students/1
  # DELETE /students/1.json
  def destroy
    authorize @student
    @student.destroy
    respond_to do |format|
      format.html { redirect_to students_url, notice: t('controller.students.destroy.notice.success') }
      format.json { head :no_content }
    end
  end

  def destroy_all
    Student.destroy(params[:s])
    render js: %(window.location.href='#{students_url}') and return
  end

  def new_import_csv
  end

  def csv_upload
    Student.import(params[:csv], current_school)
  end

  def export_csv
    students = Student.where(:id => params[:s])
    send_data(students.to_csv_file,
      type: 'text/csv; charset=iso-8859-1; header=present',
      disposition: 'attachment',
      filename: "eleves-#{Date.today}.csv")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:firstname, :lastname, :school_id, :classroom, :level, :code)
    end
end
