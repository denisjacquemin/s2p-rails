class RatingCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_rating_comment, only: [:show, :edit, :update, :destroy]

  layout :false

  # GET /rating_comments
  # GET /rating_comments.json
  def index
  end

  # GET /rating_comments/1
  # GET /rating_comments/1.json
  def show
  end

  # GET /rating_comments/new
  def new
    @rating_comment = RatingComment.new
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # GET /rating_comments/1/edit
  def edit
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # POST /rating_comments
  # POST /rating_comments.json
  def create
    @rating_comments = RatingComment.by_school(current_school.id).ordered
    @rating_comment = RatingComment.new(rating_comment_params)
    @rating_comment.school_id = current_school.id
    @rating_comment.order = @rating_comments.size

    respond_to do |format|
      if @rating_comment.save
        format.html { redirect_to @rating_comment, notice: 'Rating comment was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @rating_comment }
      else
        format.html { render :new }
        format.js
        format.json { render json: @rating_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rating_comments/1
  # PATCH/PUT /rating_comments/1.json
  def update
    respond_to do |format|
      if @rating_comment.update(rating_comment_params)
        @rating_comments = RatingComment.by_school(current_school.id).ordered

        clean_order(@rating_comments.pluck(:id))
        
        format.html { redirect_to @rating_comment, notice: 'Rating comment was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @rating_comment }
      else
        format.html { render :edit }
        format.json { render json: @rating_comment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_orders
    rating_comments = {}
    params[:orders].each_with_index do |c, index|
      rating_comments[c] = {order: index} 
    end
    RatingComment.update(rating_comments.keys, rating_comments.values)
    head :ok, content_type: "text/html"
  end

  # DELETE /rating_comments/1
  # DELETE /rating_comments/1.json
  def destroy
    @rating_comment.destroy
    respond_to do |format|
      @rating_comments = RatingComment.by_school(current_school.id).ordered

      clean_order(@rating_comments.pluck(:id))

      format.html { redirect_to rating_comments_url, notice: 'Rating comment was successfully destroyed.' }
      format.js
      format.json { head :no_content }
    end
  end

  private

    def clean_order(current_rating_comments)
      rating_comments = {}
      
      current_rating_comments.each_with_index do |c, index|
        rating_comments[c] = {order: index} 
      end
      RatingComment.update(rating_comments.keys, rating_comments.values)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_rating_comment
      @rating_comment = RatingComment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_comment_params
      params.require(:rating_comment).permit(:name)
    end
end
