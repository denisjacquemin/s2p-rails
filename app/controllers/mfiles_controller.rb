class MfilesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mfile, only: [:show, :edit, :update, :destroy]
  before_action :set_s3_direct_post, only: [:new, :edit, :create, :update]

  # GET /mfiles
  # GET /mfiles.json
  def index
    @mfiles = Mfile.all
  end

  # GET /mfiles/1
  # GET /mfiles/1.json
  def show
  end

  # GET /mfiles/new
  def new
    @mfile = Mfile.new
  end

  # GET /mfiles/1/edit
  def edit
  end

  # POST /mfiles
  # POST /mfiles.json
  def create
    @mfile = Mfile.new(mfile_params)
    if @mfile.save
      render {}
    else
      #todo
    end
  end

  # PATCH/PUT /mfiles/1
  # PATCH/PUT /mfiles/1.json
  def update
    respond_to do |format|
      if @mfile.update(mfile_params)
        format.html { redirect_to @mfile, notice: 'Mfile was successfully updated.' }
        format.json { render :show, status: :ok, location: @mfile }
        format.js   {}
      else
        format.html { render :edit }
        format.json { render json: @mfile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mfiles/1
  # DELETE /mfiles/1.json
  def destroy
    @mfile.destroy
    redirect_to edit_message_path(@mfile.message, t: 'files'), notice: 'Le message a été mis à jour.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mfile
      @mfile = Mfile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mfile_params
      params.require(:mfile).permit(:filename, :file_url, :school_id, :message_id)
    end

    def set_s3_direct_post
      @s3_direct_post = S3_BUCKET.presigned_post(key: "uploads/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end
end
