class PeriodsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_period, only: [:show, :edit, :update, :destroy]

  layout :false

  # GET /periods
  # GET /periods.json
  def index
    @periods = Period.by_school(current_school.id).ordered
  end

  # GET /periods/1
  # GET /periods/1.json
  def show
  end

  # GET /periods/new
  def new
    @period = Period.new
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # GET /periods/1/edit
  def edit
    respond_to do |format|
      format.html 
      format.js
    end
  end

  # POST /periods
  # POST /periods.json
  def create
    @periods = Period.by_school(current_school.id).ordered
    @period = Period.new(period_params)
    @period.school_id = current_school.id
    @period.order = @periods.size

    respond_to do |format|
      if @period.save
        
        format.html { redirect_to @period, notice: 'Period was successfully created.' }
        format.js
        format.json { render :show, status: :created, location: @period }
      else
        format.html { render :new }
        format.js
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /periods/1
  # PATCH/PUT /periods/1.json
  def update
    respond_to do |format|
      if @period.update(period_params)
        @periods = Period.by_school(current_school.id).ordered
        
        clean_order(@periods.pluck(:id))

        format.html { redirect_to @period, notice: 'Period was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @period }
      else
        format.html { render :edit }
        format.json { render json: @period.errors, status: :unprocessable_entity }
      end
    end
  end

  def update_orders
    periods = {}
    params[:orders].each_with_index do |c, index|
      periods[c] = {order: index} 
    end
    Period.update(periods.keys, periods.values)
    head :ok, content_type: "text/html"
  end

  # DELETE /periods/1
  # DELETE /periods/1.json
  def destroy
    @period.destroy
    respond_to do |format|
      @periods = Period.by_school(current_school.id).ordered

      clean_order(@periods.pluck(:id))

      format.html { redirect_to periods_url, notice: 'Period was successfully destroyed.' }
      format.js
      format.json { head :no_content }
    end
  end

  private

    def clean_order(current_periods)
      periods = {}
      
      current_periods.each_with_index do |c, index|
        periods[c] = {order: index} 
      end
      Period.update(periods.keys, periods.values)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_period
      @period = Period.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def period_params
      params.require(:period).permit(:name)
    end
end
