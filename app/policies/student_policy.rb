class StudentPolicy < ApplicationPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    @current_user = current_user
    @student = model
  end

  def destroy?
    # user cannot destroy a student
    return false if @current_user.user?

    # admin can only destroy students from their school
    return false if @current_user.admin? and @current_user.school_id != @student.school_id

    # superadmin and admin can destroy a student
    @current_user.admin? || @current_user.superadmin?
  end

  def edit?
    # if current_user is admin then can edit only students with the same school
    return false if @current_user.admin? and @current_user.school != @student.school

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
