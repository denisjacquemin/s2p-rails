class SchoolPolicy < ApplicationPolicy

  def index?
    verify_is_superadmin?
  end

  def show?
    verify_is_superadmin?
  end

  def create?
    verify_is_superadmin?
  end

  def new?
    verify_is_superadmin?
  end

  def update?
    # return true if superadmin
    return true if @user.superadmin?

    # return true if admin et record.school_id est inclu dans la liste des admin.schools
    return true if @user.admin? and @user.schools.include?(@record.id)

    return false
  end

  def edit?
    # return true if superadmin
    return true if @user.superadmin?

    # return true if admin et record.school_id est inclu dans la liste des admin.schools
    return true if @user.admin? and @user.schools.include?(@record.id)

    return false
  end

  def destroy?
    verify_is_superadmin?
  end

  private

  def verify_is_superadmin?
    @user.superadmin?
  end
end
