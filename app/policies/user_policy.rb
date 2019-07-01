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
    return true if @user.admin? and (@user.schools & @record.schools).any?

    # if user is a user then can edit only his own accout
    return true if @user.user? and (@user.id == @record.id)

    return @user.superadmin?

    return false
  end

  def edit_competency_groups?
    # if user is admin then can edit only user with the same school
    return true if @user.admin? and (@user.schools & @record.schools).any?

    return @user.superadmin?

    return false
  end



  def update?
    # if user is admin then can edit only user with the same school
    return true if @user.admin? and (@user.schools & @record.schools).any?

    # if user is a user then can edit only his own accout
    return true if @user.user? and (@user.id == @record.id)

    return @user.superadmin?

    return false

  end

  def update_competency_groups?
    return true if @user.admin? and (@user.schools & @record.schools).any?
    
    return @user.superadmin?

    return false
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
