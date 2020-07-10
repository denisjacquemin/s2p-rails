class RatingYearsController < ApplicationController
  before_action :set_rating_year, only: [:show, :edit, :update, :destroy]

  # GET /rating_years
  # GET /rating_years.json
  def index
    @rating_years = RatingYear.by_school(current_school.id).ordered
  end

  # GET /rating_years/1
  # GET /rating_years/1.json
  def show
  end

  # GET /rating_years/new
  def new
    @rating_year = RatingYear.new
    @rating_year.groups = Group.only_level.by_school(current_school.id)
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # GET /rating_years/1/edit
  def edit
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # POST /rating_years
  # POST /rating_years.json
  def create
    @rating_years = RatingYear.by_school(current_school.id).ordered
    @rating_year = RatingYear.new(rating_year_params)
    @rating_year.school_id = current_school.id
    @rating_year.order = @rating_years.size

    respond_to do |format|
      if @rating_year.save
        format.html { redirect_to @rating_year, notice: 'Rating year was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @rating_year }
      else
        format.html { render :new }
        format.js
        format.json { render json: @rating_year.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /rating_years/1
  # PATCH/PUT /rating_years/1.json
  def update
    respond_to do |format|
      if @rating_year.update(rating_year_params)
        @rating_years = RatingYear.by_school(current_school.id).ordered

        clean_order(@rating_years.pluck(:id))

        format.html { redirect_to @rating_year, notice: 'Rating year was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @rating_year }
      else
        format.html { render :edit }
        format.json { render json: @rating_year.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_orders
    rating_years = {}
    params[:rating_years].each_with_index do |c, index|
      rating_years[c] = {order: index} 
    end
    RatingYear.update(rating_years.keys, rating_years.values)
    head :ok, content_type: "text/html"
  end

  # DELETE /rating_years/1
  # DELETE /rating_years/1.json
  def destroy
    @rating_year.destroy
    respond_to do |format|
      @rating_years = RatingYear.by_school(current_school.id).ordered

      clean_order(@rating_years.pluck(:id))

      format.html { redirect_to rating_years_url, notice: 'Rating year was successfully destroyed.' }
      format.js
      format.json { head :no_content }
    end
  end

  private

    def clean_order(current_rating_years)
      rating_years = {}
      
      current_rating_years.each_with_index do |c, index|
        rating_years[c] = {order: index} 
      end
      RatingYear.update(rating_years.keys, rating_years.values)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_rating_year
      @rating_year = RatingYear.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def rating_year_params
      params.require(:rating_year).permit(:name, :order, :all_groups, group_ids: [])
    end
end
