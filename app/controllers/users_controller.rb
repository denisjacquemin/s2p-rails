class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update, :destroy, :resend_invite, :update_schools]

  def new_announcements_viewed
    @user = current_user
    @new_announcements_viewed_params = new_announcements_viewed_params

    @user.update(new_announcement_counter: @new_announcements_viewed_params[:count])
    render nothing: true, status: 200
  end

  def index
    @users = User.where('? = ANY (schools)', current_school.id).order(lastname: :asc).no_superadmin.active
    @users = User.all if current_user.superadmin?
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
    @user_params['schools'] = user_params[:schools].reject { |c| c.empty? } unless user_params[:schools].nil?

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
    @user.schools = @user.schools + @user.schools + submitted_schools_to_add.map(&:to_i) if submitted_schools_to_add.any?
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
      params.require(:user).permit(:firstname, :lastname, :email, :role, :phone, :function, :email_reply_to, :display_email_address, :send_email_to_author, :send_email_to_admin, :schools => [], :group_ids => [], :student_ids => [])
    end

    def new_announcements_viewed_params
      params.permit(:count)
    end

end
