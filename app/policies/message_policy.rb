class MessagePolicy < ApplicationPolicy

  def index?
    true
  end

  def show?
    false
  end

  def create?
    true
  end

  def new?
    true
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

  def update_amount_to_pay?
    # return true if admin et record.school_id est inclu dans la liste des admin.schools
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    # return true if user et message.owner est user
    return true if @user.user? and @record.author === @user

    return false
  end

  def publish?
    # return true if admin et record.school_id est inclu dans la liste des admin.schools
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    # only author can publish a message
    return true if @record.author === @user

    return true if @user.superadmin?

    return false
  end

  def republish?
    # return true if admin et record.school_id est inclu dans la liste des admin.schools
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    # only author can publish a message
    # return true if @record.author === @user

    return true if @user.superadmin?

    return false
  end

  def unpublish?

    # admin can unpublish
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    # user can unpublish own message
    return true if @user.user? and @record.author === @user

    # superadmin can unpublish
    return true if @user.superadmin?

    return false
  end

  def send_for_approval?
    # user can send for approval own message
    return true if @user.user? and @record.author === @user

    return false
  end

  def accept?
    # admin can accept
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    return false
  end

  def reject?
    # admin can reject
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    return false
  end

  def update_groups?
    # return true if superadmin
    return true if @user.superadmin?

    # admin can update groups
    return true if @user.admin? and @user.schools.include?(@record.school_id)

    # user can update groups for own message
    return true if @user.user? and @record.author === @user

    return false
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
