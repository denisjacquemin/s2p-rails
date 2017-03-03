class FaqController < ApplicationController
  def show
    @admins = current_school.admins
  end

  def help
  end
end
