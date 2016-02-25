class UserPolicy < ApplicationPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @user = model
  end

  def index?
    @current_user.superadmin? || @current_user.admin?
  end

  def destroy?
    # only superadmin can destroy an admin
    return false if @user.admin? and ! @current_user.superadmin?

    # cannot destroy superadmin
    return false if @user.superadmin?

    # only admin and superadmin can destroy a user
    @current_user.admin? || @current_user.superadmin?
  end

  def edit?
    # if current_user is admin then can edit only user with the same school
    return false if @current_user.admin? and @current_user.school != @user.school

    # only admin and superadmin can edit a user
    @current_user.admin? || @current_user.superadmin?
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user  = user
      @scope = scope
    end

    def resolve
      if user.superadmin?
        scope.all
      else
        scope.where(school_id: user.school_id)
      end
    end
  end

end
