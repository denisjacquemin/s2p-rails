# require 'charlock_holmes/string'
class StudentsController < ApplicationController
  include Code

  before_action :authenticate_user!
  before_action :set_student, only: [:show, :edit, :update, :update_groups, :destroy]

  # GET /students
  # GET /students.json
  def index
    @current_school = current_school
    #@students = current_user.students_by_school(@current_school.id)
    @message = Message.new

    # sync order by with algolia default ranking parameters
    @first_500_students = Student.includes([:phones, :student_emails]).by_school(@current_school.id).order("NULLIF(level, '') NULLS LAST, lastname").limit(100)
    @total_of_students = Student.by_school(@current_school.id).count
  end

  def students_recipients
    render json: StudentDatatable.new(params, view_context: view_context, current_user: current_user, current_school_id: current_school.id)
  end

  def new_index
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
    @student.phones.new
    @student.student_emails.new
    @student.message_categories = MessageCategory.by_school(current_school.id) if current_school.iscity?

    authorize @student
  end

  # GET /students/1/edit
  def edit
    authorize @student
    @student.phones.new
    @student.student_emails.new
  end

  # POST /students
  # POST /students.json
  def create
    @student = Student.new(student_params)
    @student.school_id = current_school.id if current_user.admin?

    authorize @student

    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    @student.groups = submitted_groups_ids.map(&:to_i) if submitted_groups_ids.present?

    student_key = shake_name(@student.firstname,@student.lastname).join
    hash = compute_code(@student.school_id, student_key)
    @student.code = 's' + hash[0] + hash[1].last(4 + student_key.length % 3)
    recordUniqueCount = 0
    begin
      @student.save
      # update_students_emails(@student, params[:student][:emails]) unless params[:student][:emails].empty?
    rescue ActiveRecord::RecordNotUnique => e
      recordUniqueCount = recordUniqueCount + 1
      @student.code = 's' + hash[0] + hash[1].last(4 + recordUniqueCount + student_key.length % 3)
      retry
    end
    if @student.errors.any?
      render :new
    else
      redirect_to edit_student_path(@student), notice: t('controller.students.create.notice.success', entity: current_school.iscity ? "Citoyen" : "Elève")
    end
  end

  # PATCH/PUT /students/1
  # PATCH/PUT /students/1.json
  def update
    authorize @student

    submitted_groups_ids = params[:group][:id] unless params[:group].nil?
    @student.groups = submitted_groups_ids.map(&:to_i) if submitted_groups_ids.present?

    if @student.update(student_params)
      redirect_to edit_student_path(@student), notice: t('controller.students.update.notice.success', entity: current_school.iscity ? "Citoyen" : "Elève")
    else
      render :edit
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
      format.html { redirect_to students_url, notice: t('controller.students.destroy.notice.success', entity: current_school.iscity ? "Citoyen" : "Elève") }
      format.json { head :no_content }
    end
  end

  def destroy_all
    ActiveRecord::Base.transaction do
      students = Student.where(school_id: current_school.id) unless params[:all_students].nil?
      students = Student.where(id: params[:student][:id], school_id: current_school.id) unless params[:student].nil?

      students.destroy_all
      # Student.where(id: params[:student][:id]).destroy_all
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
    validation = Sheet::validate_file(params[:csv])
    unless validation[:isValid]
      case validation[:reason]
        when :nil
          render :csv, :locals => { :error_message => validation[:error_message] } and return
        when :mime
          render :csv, :locals => { :error_message => validation[:error_message] } and return
      end
    end

    # test encoding
    encoding = Sheet::encoding(params[:csv])
    format = Sheet::RooFormat(params[:csv])
    if format == :csv
      begin
        # content = File.read(params[:csv].tempfile.path)
        # detection = CharlockHolmes::EncodingDetector.detect(content)
        delimiters = [',',";"]
        col_sep = sniff(params[:csv].tempfile.path, delimiters, encoding)
        options = {
          :unwanted_row => nil,
          :force_simple_split => false,
          :col_sep => col_sep,
          :strip_chars_from_headers => /[\-"]/,
          :quote_char => '"',
          :chunk_size => 500,
          :key_mapping => {
            :prenom => :firstname,
            :nom => :lastname,
            :emails => :emails,
            :envoi_des_messages_via_email => :sent_message_by_email,
            :annee => :level,
            :entite => :level,
            :titulaire => :classroom,
            :rue => :classroom,
            :code => :code,
            # keys from WinPage ou Creos
            "classe_(libellé)".to_sym  => :level,
             "prénom".to_sym  => :firstname,
            :nom_du_titulaire => :classroom,
            "prénom_du_titulaire".to_sym => :firstname_classroom,
            "courriel_de_l'élève".to_sym  => :emails,
            "courriel_signataire".to_sym => :emails2,
            "matricule".to_sym => :winpage_matricule,
            "telephone_1".to_sym => :phone1,
            "telephone_2".to_sym => :phone2,
            "telephone_3".to_sym => :phone3,
             "telephone_4".to_sym => :phone4,
            "téléphone_1".to_sym => :phone1,
            "téléphone_2".to_sym => :phone2,
            "téléphone_3".to_sym => :phone3,
            # "gsm".to_sym => :phone4,
            "Implantation".to_sym => :implantation,
            "titulaire_nom".to_sym => :classroom,
            "titulaire_prénom".to_sym => :firstname_classroom,
            "informations_de_contact".to_sym => :info_contact,
            "personnes_responsables_informations_de_contact_1".to_sym => :info_contact1,
            "personnes_responsables_informations_de_contact_2".to_sym => :info_contact2,
            "personnes_responsables_informations_de_contact_3".to_sym => :info_contact3,
            "personnes_responsables_informations_de_contact_4".to_sym => :info_contact4,
            "personnes_responsables_informations_de_contact_5".to_sym => :info_contact5,
            "personnes_responsables_informations_de_contact_6".to_sym => :info_contact6,
            "personnes_responsables_informations_de_contact_7".to_sym => :info_contact7,
            "personnes_responsables_informations_de_contact_8".to_sym => :info_contact8,
            "personnes_responsables_informations_de_contact_9".to_sym => :info_contact9,
            "gsm".to_sym => :info_contact1,
            "email".to_sym => :info_contact2,
            "personnes_responsables_gsm".to_sym => :info_contact3,
            "personnes_responsables_email".to_sym => :info_contact4,
            "personnes_responsables_telephone".to_sym => :info_contact5,
            # :classe => :level2, # champ Creos mais deja supporté grace à ProEco
            # keys from ProEco
            :matric_info => :proeco_id,
            :nom_elève => :lastname,
            :prénom_elève => :firstname,
            :gsm_père => :phone1,
            :gsm_mère => :phone2,
            :année => :level1,
            :annee => :level1,
            :classe => :level2,
            :email_père => :email1,
            :email_mère => :email3,
            :grpel => :classroom,
            # SIEL
            "annee_d'etude".to_sym => :siel_annee_etude,
            "nom_tit".to_sym => :siel_nom_tit,
            "prénom_tit".to_sym => :siel_prenom_tit,
            "eleve".to_sym => :siel_id,
            "email_responsable_1".to_sym => :siel_email_1,
            "email_responsable_2".to_sym => :siel_email_2,
            "tel_1_responsable_1".to_sym => :phone1,
            "tel_2_responsable_1".to_sym => :phone2,
            # gestscol
            #             :nom => :lastname,
            #             "prénom".to_sym  => :firstname,
            #             :année => :level1,
            #             :annee => :level,
            #             :classe => :level2,
            "mèl_resp_1".to_sym => :email1,
            "mèl_resp_2".to_sym => :email3,
            "tél.1_resp.1".to_sym => :phone1,
            "tél.1_resp.2".to_sym => :phone2,
          },
          :remove_unmapped_keys => true,
          :value_converters => {
            :sent_message_by_email => SentMessageByEmailConverter
          },
          :file_encoding => encoding #detection[:encoding]
        }
        content = File.read(params[:csv].tempfile.path)
        # detection = CharlockHolmes::EncodingDetector.detect(content)
        # utf8_encoded_content = CharlockHolmes::Converter.convert contents, detection[:encoding], 'UTF-8'
        current_school_id = current_school.id
        SmarterCSV.process(params[:csv].tempfile.path, options) do |r|
          CreateStudentFromCsvV2Job.perform_later(r, current_school.id, current_user)
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
    # elsif format == :xls
    #   xls = Roo::Spreadsheet.open(params[:csv].tempfile.path, extension: :xls)
    #
    #   xls.sheet(0).each(id: 'ID', name: 'FULL_NAME') do |hash|
    #     puts hash.inspect
    #     # => { id: 1, name: 'John Smith' }
    #   end
    end
    render :locals => { :error_message => '', :message => t('controller.students.cvs_upload.notice.success') }
  end

  def export_csv
    students = Student.default_order.includes([:phones, :student_emails]).where(school_id: current_school.id) unless params[:all_students].nil?
    students = Student.default_order.includes([:phones, :student_emails]).where(id: params[:student][:id], school_id: current_school.id) unless params[:student].nil?
    file_name = current_school.iscity ? "citoyens-" : "eleves-"
    send_data(students.to_csv_file(current_school.iscity).encode("cp1252"),
      type: 'text/csv; charset=iso-8859-1; header=present',
      disposition: 'attachment',
      filename: "#{file_name}#{current_school.name.parameterize}-#{Date.today}.csv")
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_student
      @student = Student.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def student_params
      params.require(:student).permit(:firstname, :lastname, :school_id, :classroom, :level, :code, :sent_message_by_email, :emails, "message_category_ids" => [], student_emails_attributes: [:id, :email, :_destroy], phones_attributes: [:id, :number, :owner_name, :_destroy])
    end


end
