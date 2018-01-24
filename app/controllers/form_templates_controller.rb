class FormTemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_form_template, only: [:show, :edit, :update, :destroy]

  # GET /form_templates
  # GET /form_templates.json
  def index
    @form_templates = policy_scope(FormTemplate).where(school_id: current_school.id).order(created_at: :desc)
  end

  # GET /form_templates/new
  def new
    @form_template = FormTemplate.new
  end

  # GET /form_templates/1/edit
  def edit
    authorize @form_template
  end

  # POST /form_templates
  # POST /form_templates.json
  def create
    @form_template = FormTemplate.new(form_template_params)
    @form_template.school_id = current_school.id
    @form_template.author_id = current_user.id

    authorize @form_template

    if @form_template.save
      redirect_to edit_form_template_path(@form_template) , notice: 'Le formulaire a été créé avec succès.'
    else
      render :new
    end
  end

  # PATCH/PUT /form_templates/1
  # PATCH/PUT /form_templates/1.json
  def update
    authorize @form_template

    if @form_template.update(form_template_params)
      redirect_to edit_form_template_path(@form_template) , notice: 'Le formulaire a été enregistré avec succès.'
    else
      render :edit
    end
  end

  # DELETE /form_templates/1
  # DELETE /form_templates/1.json
  def destroy
    @form_template.destroy
    respond_to do |format|
      format.html { redirect_to form_templates_url, notice: 'Form template was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def load_form_template
    @form_template = FormTemplate.find(params[:form_template_id])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_form_template
      @form_template = FormTemplate.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def form_template_params
      params.require(:form_template).permit(:name, :formdata)
    end
end
