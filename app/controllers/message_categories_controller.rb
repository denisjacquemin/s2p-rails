class MessageCategoriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message_category, only: [:show, :edit, :update, :destroy]

  # GET /message_categories
  # GET /message_categories.json
  def index
    @message_categories = MessageCategory.by_school(current_school.id)
    authorize @message_categories
  end

  # GET /message_categories/1
  # GET /message_categories/1.json
  def show
    authorize @message_category
  end

  # GET /message_categories/new
  def new
    @message_category = MessageCategory.new
    authorize @message_category
  end

  # GET /message_categories/1/edit
  def edit
    authorize @message_category
  end

  # POST /message_categories
  # POST /message_categories.json
  def create
    @message_category = MessageCategory.new(message_category_params)
    @message_category.school_id = current_school.id
    authorize @message_category
    if @message_category.save
      redirect_to edit_message_category_path(@message_category) , notice: 'La catégorie a été créée avec succès.'
    else
      render :new
    end
  end

  # PATCH/PUT /message_categories/1
  # PATCH/PUT /message_categories/1.json
  def update
    authorize @message_category
    if @message_category.update(message_category_params)
      redirect_to edit_message_category_path(@message_category) , notice: 'La catégorie a été enregistrée avec succès.'
    else
      render :edit
    end
  end

  # DELETE /message_categories/1
  # DELETE /message_categories/1.json
  def destroy
    authorize @message_category
    @message_category.destroy
    respond_to do |format|
      format.html { redirect_to message_categories_url, notice: 'Message category was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message_category
      @message_category = MessageCategory.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def message_category_params
      params.require(:message_category).permit(:name)
    end
end
