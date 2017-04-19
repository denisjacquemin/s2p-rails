# require 'charlock_holmes/string'
class StudentsController < ApplicationController
  include Code

  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :update_groups, :destroy]

  # GET /students
  # GET /students.json
  def index
    @students = current_user.students_by_school(current_school.id)
    @message = Message.new
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
    if current_user.admin?
      @student.school_id = current_school.id
    end
    authorize @student
    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    @student.groups = submitted_groups_ids.map(&:to_i) if submitted_groups_ids.present?

    student_key = shake_name(@student.firstname,@student.lastname).join
    hash = compute_code(@student.school_id, student_key)
    @student.code = 's' + hash[0] + hash[1].last(4 + student_key.length % 3)
    recordUniqueCount = 0
    begin
      @student.save
    rescue ActiveRecord::RecordNotUnique => e
      recordUniqueCount = recordUniqueCount + 1
      @student.code = 's' + hash[0] + hash[1].last(4 + recordUniqueCount + student_key.length % 3)
      retry
    end
    if @student.errors.any?
      render :new
    else
      redirect_to edit_student_path(@student), notice: t('controller.students.create.notice.success')
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    authorize @student

    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    @student.groups = submitted_groups_ids.map(&:to_i) if submitted_groups_ids.present?
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

    actual_groups_to_delete = actual_groups_ids - submitted_groups_ids.map(&:to_i) if submitted_groups_ids.present?

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
    ActiveRecord::Base.transaction do
      Student.where(id: params[:s]).delete_all
    end
    render js: %(window.location.href='#{students_url}') and return
  end

  def new_import_csv
    render :csv, :locals => { :error_message => nil }
  end

  class SentMessageByEmailConverter
    def self.convert(value)
      if value.downcase === "oui" then true else false end
    end
  end



  def sniff(path, delimiters, encoding)
    first_line = File.open(path, "r:#{encoding}").first
    return nil unless first_line
    snif = {}
    delimiters.each {|delim|snif[delim]=first_line.count(delim)}
    snif = snif.sort {|a,b| b[1]<=>a[1]}
    snif.size > 0 ? snif[0][0] : nil
  end

  def csv_upload
    if params[:csv].nil?
      render :csv, :locals => { :error_message => 'Aucun fichier à importer', message: '' } and return
    end


    # test file mime type
    mimemagic = MimeMagic.by_path(params[:csv].tempfile.path)

    if (mimemagic.type != "text/csv")
      render :csv, :locals => { :error_message => 'Format de fichier invalide', message: '' } and return
    end

    # test encoding
    encoding = 'utf-8'
    begin
      begin
        lines = CSV.read(params[:csv].tempfile.path, :encoding => encoding, :quote_char => '"')
      rescue ArgumentError
        encoding = 'ISO-8859-1'
      end

      # content = File.read(params[:csv].tempfile.path)
      # detection = CharlockHolmes::EncodingDetector.detect(content)
      delimiters = [',',";"]
      col_sep = sniff(params[:csv].tempfile.path, delimiters, encoding)
      options = {
        :unwanted_row => nil,
        :force_simple_split => true,
        :col_sep => col_sep,
        :strip_chars_from_headers => /[\-"]/,
        :chunk_size => 1000,
        :key_mapping => {
          :prenom => :firstname,
          :nom => :lastname,
          :emails => :emails,
          :envoi_des_messages_via_email => :sent_message_by_email,
          :annee => :level,
          :titulaire => :classroom,
          :code => :code
        },
        :remove_unmapped_keys => true,
        :value_converters => {
          :sent_message_by_email => SentMessageByEmailConverter
        },
        :file_encoding => encoding #detection[:encoding]
      }
      # content = File.read(params[:csv].tempfile.path)
      # detection = CharlockHolmes::EncodingDetector.detect(content)
      # utf8_encoded_content = CharlockHolmes::Converter.convert contents, detection[:encoding], 'UTF-8'

      current_school_id = current_school.id
      SmarterCSV.process(params[:csv].tempfile.path, options) do |r|
        CreateStudentFromCsvJob.perform_later(r, current_school.id, current_user)
        # r.each do |data|
        #   #CreateStudentFromCsvJob.perform_later(data, current_school.id, current_user)
        #   groups = []
        #
        #   data['school_id'] = current_school_id
        #
        #   student = nil
        #   if (data[:code].nil?)
        #     student = Student.where(['firstname = ? and lastname = ? and school_id = ?', data[:firstname], data[:lastname], data['school_id']] ).first
        #   else
        #     student = Student.where(['code = ?', data[:code]]).first
        #   end
        #
        #   if student.nil?
        #     @student = Student.new data
        #     logger.info "student to create #{@student.inspect}"
        #     if policy(@student).create?
        #       if @student.save
        #         logger.info "student #{@student.firstname} #{@student.lastname} successfully created"
        #       else
        #         logger.info "student create fail for #{@student.firstname} #{@student.lastname} #{@student.errors}"
        #       end
        #     end
        #   else
        #     if policy(student).update? and current_school_id == student.school_id
        #       if student.update_attributes(data)
        #         logger.info "student #{student.firstname} #{student.lastname} updated"
        #       else
        #         logger.info "student update fail for #{student.firstname} #{student.lastname}"
        #       end
        #     else
        #       logger.info "student update fail for, invalid authorization"
        #     end
        #   end
        # end
      end
    rescue Exception => e
      render :csv, :locals => { :error_message => e.message, message: '' } and return
    end
    render :locals => { :error_message => '', :message => t('controller.students.cvs_upload.notice.success') }
  end

  def export_csv
    students = Student.where(:id => params[:s])
    send_data(students.to_csv_file.encode("iso-8859-1"),
      type: 'text/csv; charset=iso-8859-1; header=present',
      disposition: 'attachment',
      filename: "eleves-#{current_school.name.parameterize}-#{Date.today}.csv")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:firstname, :lastname, :school_id, :classroom, :level, :code, :sent_message_by_email, :emails)
    end
end
