class MessagePolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    return false
  end

  def create?
    @user.superadmin?
  end

  def new?
    @user.superadmin?
  end

  def update?
    @user.superadmin?
  end

  def publish?
    @user.superadmin?
  end

  def unpublish?
    @user.superadmin?
  end

  def send_for_approval?
    @user.superadmin?
  end

  def accept?
    @user.superadmin?
  end

  def reject?
    @user.superadmin?
  end

  def update_groups?
    @user.superadmin?
  end

  def edit?
    return false if not @user.schools.include?(@record.school_id)

    @user.superadmin?
  end

  def destroy?
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
      elsif user.admin?
        scope.where(school_id: user.schools)
      elsif user.user?
        scope.where(school_id: user.schools, author_id: user.id)
      end
    end
  end
end
