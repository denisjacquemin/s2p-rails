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
    verify_is_superadmin?
  end

  def edit?
    verify_is_superadmin?
  end

  def destroy?
    verify_is_superadmin?
  end

  private

  def verify_is_superadmin?
    @user.superadmin?
  end
end
