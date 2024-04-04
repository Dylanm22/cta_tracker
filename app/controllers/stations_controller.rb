require 'httparty'
class StationsController < ApplicationController
  before_action :set_station, only: %i[ show edit update destroy ]

  # GET /stations or /stations.json
  def index
    @stations = Station.all
  end
  # GET /stations/1 or /stations/1.json
  def show
    @is_show_page = true
    @station = Station.find(params[:id])
    @favorite = Favorite.new
    @stations = Station.all
    api_key = ENV["CTA_KEY"].strip
     num = @station.map
     response = HTTParty.get("http://lapi.transitchicago.com/api/1.0/ttarrivals.aspx?key=#{api_key}&mapid=#{num}&outputType=JSON")
     stops = JSON.parse(response.body)['ctatt']['eta']

     @arrivals = []
     stops.each do |stop|
       @arrivals.push({
         name: stop['staNm'],
         run_number: stop['rn'],
         line: stop['rt'],
         destination: stop['destNm'],
         eta: stop['arrT']
       })
    end
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.replace('content-to-update', partial: 'stations/show_content', locals: { station: @station }) }
      format.html # Render the HTML format as usual
    end
  end
  # GET /stations/new
  def new
    @station = Station.new
  end
  
  # GET /stations/1/edit
  def edit
  end

  # POST /stations or /stations.json
  def create
    @station = Station.new(station_params)

    respond_to do |format|
      if @station.save
        format.html { redirect_to station_url(@station), notice: "Station was successfully created." }
        format.json { render :show, status: :created, location: @station }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stations/1 or /stations/1.json
  def update
    respond_to do |format|
      if @station.update(station_params)
        format.html { redirect_to station_url(@station), notice: "Station was successfully updated." }
        format.json { render :show, status: :ok, location: @station }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stations/1 or /stations/1.json
  def destroy
    @station.destroy

    respond_to do |format|
      format.html { redirect_to stations_url, notice: "Station was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_station
      @station = Station.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def station_params
      params.require(:station).permit(:name, :map)
    end
end
