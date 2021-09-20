class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action do
    helpers.authorize_current_school(current_user, current_school.id)
  end
  before_action :set_user, only: [:edit, :update, :destroy, :resend_invite, :update_schools, :group_rights_for_report, :competency_rights_for_report]

  def new_announcements_viewed
    @user = current_user
    @new_announcements_viewed_params = new_announcements_viewed_params

    @user.update(new_announcement_counter: @new_announcements_viewed_params[:count])
    render head: :ok
  end

  def group_rights_for_report
    allow_access = params[:user][:allow_access]
    group_id = params[:user][:group_id]
    group = Group.find group_id
    if allow_access == "1"
      report_group_user = ReportGroupUser.find_or_create_by(user_id: @user.id, group_id: group_id)
      report_group_user.update(allowed: true)
    else
      report_group_user = ReportGroupUser.find_or_create_by(user_id: @user.id, group_id: group_id)
      report_group_user.update(allowed: false)
    end
  end

  def competency_rights_for_report
    allow_access = params[:user][:allow_access]
    competency_id = params[:user][:competency_id]
    if allow_access == "1"
      report_competency_user = ReportCompetencyUser.find_or_create_by(competency_id: competency_id, user_id: @user.id)
      report_competency_user.update(allowed: true)
    else 
      report_competency_user = ReportCompetencyUser.find_or_create_by(competency_id: competency_id, user_id: @user.id)
      report_competency_user.update(allowed: false)
    end
  end

  def index
    if current_user.superadmin?
      @users = User.all
    else
      @users = User.where('? = ANY (schools)', current_school.id).order(lastname: :asc).no_superadmin.active
    end
  end

  def destroy
    authorize @user
    random = ('a'..'z').to_a.shuffle[0,8].join
    @user.update(email: @user.email + random, deleted_at: Time.current)

    redirect_to users_path, :notice => t('controller.user.destroy.success.notice')
  end

  def edit
    authorize @user
  end

  def update
    authorize @user

    @user_params = user_params

    # handle schools update
    # identifier les écoles à retirer, garder les écoles pour lesquels le @user à accès et pour lesquels le current_user n'a pas de droits   
    
    # identifier les écoles qui ne sont pas dans user_params[:schools] et qui sont dans current_user.schools
    unless user_params[:schools].blank?
      schools_to_remove = current_user.schools - user_params[:schools].map(&:to_i) || []
      schhols_to_add = user_params[:schools].map(&:to_i) - @user.schools - [0]
      @user_params['schools'] = @user.schools - schools_to_remove + schhols_to_add
    end
    # @user_params['schools'] = user_params[:schools].reject { |c| c.empty? } unless user_params[:schools].nil?

    # for each group_id, get all students_ids and assign them to @user.students_ids
    @user_params[:student_ids] = Group.where(id: @user_params[:group_ids]).collect {|g| g.students.pluck(:id)}.flatten.compact.uniq

    if @user.update(@user_params)
      redirect_to edit_user_path, :notice => t('controller.user.update.success.notice')
    else
      redirect_to edit_user_path
    end
  end

  def resend_invite
    User.invite!({:email => @user.email, :firstname => @user.firstname}, current_user)
    redirect_to users_path, notice: 'Invitation renvoyée'
  end

  def update_schools
    authorize @user
    # before update, compares the actual schools for the user against the submitted list
    actual_schools_ids = @user.schools
    submitted_schools_ids = params[:school][:id] unless params[:school].nil?
    submitted_schools_ids = [] if submitted_schools_ids.nil?

    # get the ids to be removed (remove_groups)
    actual_schools_to_delete = actual_schools_ids - submitted_schools_ids.map(&:to_i)

    # check if submited groups are not yet in db
    submitted_schools_to_add = submitted_schools_ids.select { |s| !actual_schools_ids.include?(s.to_i) }
    @user.schools = @user.schools + submitted_schools_to_add.map(&:to_i) if submitted_schools_to_add.any?
    #User.add_schools(@user.id, ) if submitted_schools_to_add.any?
    @user.schools = @user.schools - actual_schools_to_delete.map(&:to_i) if actual_schools_to_delete.any?
    #User.remove_schools(@user.id, actual_schools_to_delete) if actual_schools_to_delete.any?
    #@user.set_all_writers


    @user.save


    redirect_to edit_user_path(@user), notice: t('controller.user.update.success.notice')
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:firstname, :lastname, :email, :role, :phone, :function, :email_reply_to, :display_email_address, :send_email_to_author, :send_notification_by_email, :send_email_to_admin, :send_notification_for_approval_and_refuse, :schools => [], :group_ids => [], :student_ids => [])
    end    

    def new_announcements_viewed_params
      params.permit(:count)
    end

end
