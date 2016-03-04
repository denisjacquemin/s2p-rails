class UserPolicy < ApplicationPolicy

  def index?
    @user.superadmin? || @user.admin?
  end

  def destroy?
    # only superadmin can destroy an admin
    return false if @user.admin? and ! @user.superadmin?

    # cannot destroy superadmin
    return false if @user.superadmin?

    # only admin and superadmin can destroy a user
    @user.admin? || @user.superadmin?
  end

  def edit?
    # if user is admin then can edit only user with the same school
    return false if @user.admin? and @user.school != @user.school

    # only admin and superadmin can edit a user
    @user.admin? || @user.superadmin?
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
