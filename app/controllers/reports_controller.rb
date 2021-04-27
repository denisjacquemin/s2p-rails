class ReportsController < ApplicationController
    def parameters
        @groups = Group.where(school_id: current_school.id).only_level
        render layout: false
    end

    def writers_access
        @users = User.where('? = ANY (schools)', current_school.id).order(firstname: :asc).user.active
        @user_selected_id = params[:selected_user]
        # @competency_write_accesses = CompetencyWriterAccess.where(user_id: @user_selected_id, school_id: current_school.id)
        @competencies = Competency.where(school_id: current_school.id).order(:order)
        render layout: false
      end

    def change_user
        @user_selected_id = params[:user_selected_id]
        @user = User.find @user_selected_id
        @groups = Group.where(school_id: current_school.id).valid_class
    end

    def load_competencies_table
        @user_selected_id = params[:user_selected_id]
        @group_selected_id = params[:group_selected_id]
        @user = User.find(@user_selected_id)
        @competencies = Competency.by_school(current_school.id).where(group_id: @group_selected_id).ordered
        @competencies_access_rights = ReportCompetencyUser.where(competency_id: @competencies.pluck(:id))
    end

end