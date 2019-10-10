class RatingPolicy < ApplicationPolicy


  def index?
    return true if @user.superadmin? or @user.admin?
    
    false
  end


end