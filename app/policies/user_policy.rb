class UserPolicy < ApplicationPolicy

  def index?
    @user.superadmin? || @user.admin?
  end

  def destroy?


    # cannot destroy superadmin
    return false if @record.superadmin?

    # only admin and superadmin can destroy a user
    return false if @user.admin? and not (@user.schools & @record.schools).any?

    # only superadmin can destroy an admin
    return false if @record.admin? and ! @user.superadmin?

    @user.admin? or @user.superadmin?
  end

  def edit?
    # if user is admin then can edit only user with the same school
    return false if @user.admin? and not (@user.schools & @record.schools).any?

    # if user is a user then can edit only his own accout
    return false if @user.user? and not (@user.id == @record.id)

    return true

  end

  def update?
    # if user is admin then can edit only user with the same school
    return false if @user.admin? and not (@user.schools & @record.schools).any?

    # if user is a user then can edit only his own accout
    return false if @user.user? and not (@user.id == @record.id)

    return true

  end

  def update_schools?
    @user.superadmin?
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
