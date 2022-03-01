class FaqController < ApplicationController
  def show
    @admins = current_school.admins
  end

  def help
  end

  def whatsnew
    render :layout => false
  end

  def contact_support

  end

  def submit_support
    SupportMailer.confirm_email(
      params[:name],
      params[:email],
      params[:message]).deliver

    render 'supportconfirmation'
  end

  def submit_sdui
    SupportMailer.contact_sdui_email(
      "#{current_user.firstname} #{current_user.lastname}",
      current_user.email,
      School.find(current_user.schools).pluck(:name).join(', '),
      params[:message]).deliver

    render 'contact_sdui'

  end

  def sdui_link_clicked
    # set a counter on the current user object "saw_sdui_comm_counter" 
    # set a date on the current user object "lasttime_saw_sdui_comm_date"
    # set a flag on current_user' schools objects "saw_sdui_comm"


    # User.where('saw_sdui_comm_counter > :counter', counter: 0).pluck(:firstname, :lastname, :schools)
    # School.where('saw_sdui_comm = :flag', flag: true).pluck(:name)
    current_user.saw_sdui_comm_counter = current_user.saw_sdui_comm_counter + 1
    current_user.save

    current_user.schools.each do |school_id|
      school = School.find school_id
      unless school.nil?
        school.saw_sdui_comm = true
        school.save
      end
    end

  end
end
