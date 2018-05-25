class MessageCategoryPolicy < ApplicationPolicy

  def index?
    return true if @user.superadmin?
  end

  def destroy?
    return true if @user.superadmin?
  end

  def new?
    return true if @user.superadmin?
  end

  def create?
    return true if @user.superadmin?
  end

  def update?
    return true if @user.superadmin?
  end

  def edit?
    return true if @user.superadmin?
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
