class GroupPolicy < ApplicationPolicy

  def index?
    return true if @user.superadmin? or @user.admin?
    false
  end

  def destroy?
    # user cannot destroy a group
    return false if @user.user?

    # admin can only destroy groups from their school
    return false if @user.admin? and not @user.schools.include?(@record.school_id)

    # superadmin and admin can destroy a group
    @user.admin? || @user.superadmin?
  end

  def new?
    # superadmin and admin can create a student
    @user.admin? || @user.superadmin?
  end

  def edit?
    # if user is admin then can edit only group with the same school
    return false if @user.admin? and not @user.schools.include?(@record.school_id)

    # only admin and superadmin can edit a group
    (@user.admin? and @record.updatable) || @user.superadmin?
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
      # else
      #   scope.where(school_id: user.schools)
      end
    end
  end
end
