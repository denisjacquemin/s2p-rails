class FormTemplatePolicy < ApplicationPolicy

  def index?
    true
  end

  def create?
    return true if @user.superadmin? or @user.admin?
  end

  def new?
    return true if @user.superadmin? or @user.admin?
  end

  def edit?
    # return true if superadmin
    return true if @user.superadmin?

    # return true if admin et record.school_id est inclu dans la liste des admin.schools
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    # return true if user et message.owner est user
    return true if @user.user? and @record.author === @user

    return false
  end

  def update?
    # return true if superadmin
    return true if @user.superadmin?

    # return true if admin et record.school_id est inclu dans la liste des admin.schools
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    # return true if user et message.owner est user
    return true if @user.user? and @record.author === @user

    return false
  end

  def destroy?
    # return true if superadmin
    return true if @user.superadmin?

    # return true if admin et record.school_id est inclu dans la liste des admin.schools
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    # return true if user et message.owner est user
    return true if @user.user? and @record.author === @user

    return false
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
      elsif user.admin?
        scope.where(school_id: user.schools)
      elsif user.user?
        scope.where(school_id: user.schools, author_id: user.id)
      end
    end
  end
end
