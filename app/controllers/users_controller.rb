class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update, :destroy, :resend_invite, :update_schools]


  def index
    @users = User.where('? = ANY (schools)', current_school.id).order(firstname: :asc).active
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
    if @user.update(user_params)
      redirect_to users_path, notice: t('controller.user.update.success.notice')
    else
      render :edit
    end
  end

  def resend_invite
    User.invite!(:email => @user.email, :firstname => @user.firstname)
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

    User.add_schools(@user.id, submitted_schools_to_add.map(&:to_i)) if submitted_schools_to_add.any?
    User.remove_schools(@user.id, actual_schools_to_delete) if actual_schools_to_delete.any?
    redirect_to edit_user_path(@user), notice: 'Le message a été mis à jour.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:firstname, :lastname, :email, :role, :schools => [])
    end

end
