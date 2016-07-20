class StudentPolicy < ApplicationPolicy

  def index?
    @record.each do |student|
      if (! @user.schools.include?(student.school_id) )
        return false
      end
    end
    true
  end

  def new?
    # superadmin and admin can create a student
    @user.admin? || @user.superadmin?
  end

  def destroy?

    # user cannot destroy a student
    return false if @user.user?

    # admin can only destroy students from their school
    return false if @user.admin? and not @user.schools.include?(@record.school_id)

    # superadmin and admin can destroy a student
    @user.admin? || @user.superadmin?
  end

  def destroy_all?

    # user cannot destroy a student
    return false if @user.user?

    # admin can only destroy students from their school
    return false if @user.admin? and not @user.schools.include?(@record.school_id)

    # superadmin and admin can destroy a student
    @user.admin? || @user.superadmin?
  end


  def create?
    # only admin and superadmin can create a student
    @user.admin? || @user.superadmin?
  end

  def edit?
    # only admin and superadmin can edit a user
    return  unless @user.admin? || @user.superadmin?

    # if user is admin then can edit only students with the same school
    return false if @user.admin? and not @user.schools.include?(@record.school_id)

    true
  end

  def update?
    # only admin and superadmin can edit a user
    return  unless @user.admin? || @user.superadmin?

    # if user is admin then can edit only students with the same school
    return false if @user.admin? and not @user.schools.include?(@record.school_id)

    true
  end

  def update_groups?
    # only admin and superadmin can edit a user
    return  unless @user.admin? || @user.superadmin?

    return false if @user.admin? and not @user.schools.include?(@record.school_id)

    true
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
        scope.where(school_id: user.schools)
      end
    end
  end
end
