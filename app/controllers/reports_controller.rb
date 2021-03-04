class ReportsController < ApplicationController
    def parameters
        @groups = Group.where(school_id: current_school.id).only_level
        render layout: false
    end
end