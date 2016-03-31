class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:edit, :update, :destroy]


  def index
    @users = policy_scope(User).active
  end

  def destroy
    authorize @user
    @user.update(email: @user.email + '_deleted', deleted_at: Time.current)
    redirect_to users_path, :notice => "User deleted."
  end

  def edit
    authorize @user
  end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'User was successfully updated.'
    else
      render :edit
    end
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
