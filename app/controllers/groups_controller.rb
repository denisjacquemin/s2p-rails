class GroupsController < ApplicationController
  include Code

  before_action :authenticate_user!
  before_action do
    helpers.authorize_current_school(current_user, current_school.id)
  end
  before_action :set_group, only: [:show, :edit, :update, :update_students, :destroy]

  # GET /groups
  # GET /groups.json
  def index
    @groups = current_user.groups_by_school(current_school.id)
  end

  # GET /groups/1
  # GET /groups/1.json
  def show
  end

  # GET /groups/new
  def new
    @group = Group.new
  end

  # GET /groups/1/edit
  def edit
    authorize @group
    #@students = Student.by_group_id(@group.id)
  end

  # POST /groups
  # POST /groups.json
  def create
    @group = Group.new(group_params)
    if current_user.admin?
      @group.school_id = current_school.id
    end

    hash = compute_code(@group.school_id, @group.name)
    @group.code = 'g' + hash[0] + hash[1].last(4 + @group.name.length % 3)
    recordUniqueCount = 0
    begin
        @group.save
    rescue ActiveRecord::RecordNotUnique => e
      recordUniqueCount = recordUniqueCount + 1
      logger.debug "hash[1]: #{hash[1]} 4 + recordUniqueCount + @group.name.length % 3: #{4 + recordUniqueCount + @group.name.length % 3}"
      @group.code = 'g' + hash[0] + hash[1].last(4 + recordUniqueCount + @group.name.length % 3)
      retry
    end
    if @group.errors.any?
      render :new
    else
      redirect_to edit_group_path(@group), notice: 'Le groupe a été créé avec succès.'
    end
  end

  def update
    if @group.update(group_params)
      redirect_to edit_group_path(@group), notice: t('controller.groups.update.notice.success')
    else
      render :edit
    end
  end

  def update_students
    # before update, compares the actual members of the group to the submitted list
    actual_members_ids = @group.students.pluck(:id)
    submitted_members_ids = params[:student][:id] unless params[:student].nil?
    submitted_members_ids = [] if submitted_members_ids.nil?

    actual_members_to_delete = actual_members_ids - submitted_members_ids.map(&:to_i)

    Student.add_group(submitted_members_ids, params[:id]) if submitted_members_ids.any?
    Student.remove_group(actual_members_to_delete, params[:id]) if actual_members_to_delete.any?
    redirect_to edit_group_path(@group), notice: t('controller.groups.update.notice.success')
  end

  # DELETE /groups/1
  # DELETE /groups/1.json
  def destroy
    @group.destroy
    respond_to do |format|
      format.html { redirect_to groups_url, notice: t('controller.groups.destroy.notice.success') }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_group
      @group = Group.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def group_params
      params.require(:group).permit(:name, :school_id)
    end
end
