class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update, :destroy, :resend_invite]


  def index
    @users = policy_scope(User).order(firstname: :asc).active
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

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      params.require(:user).permit(:firstname, :lastname, :email, :role, :school_id)
    end

end
