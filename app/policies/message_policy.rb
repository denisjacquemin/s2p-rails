class MessagePolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    true
  end

  def create?
    true
  end

  def new?
    true
  end

  def update?
    true
  end

  def publish?
    true
  end

  def unpublish?
    true
  end

  def send_for_approval?
    true
  end

  def accept?
    true
  end

  def reject?
    true
  end

  def update_groups?
    true
  end

  def edit?
    true
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
