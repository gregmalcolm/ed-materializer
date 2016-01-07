class WorldSurveysController < ApplicationController
  before_action :set_world_survey, only: [:show, :update, :destroy]

  # GET /world_surveys
  # GET /world_surveys.json
  def index
    @world_surveys = WorldSurvey.all

    render json: @world_surveys
  end

  # GET /world_surveys/1
  # GET /world_surveys/1.json
  def show
    render json: @world_survey
  end

  # POST /world_surveys
  # POST /world_surveys.json
  def create
    @world_survey = WorldSurvey.new(world_survey_params)

    if @world_survey.save
      render json: @world_survey, status: :created, location: @world_survey
    else
      render json: @world_survey.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /world_surveys/1
  # PATCH/PUT /world_surveys/1.json
  def update
    @world_survey = WorldSurvey.find(params[:id])

    if @world_survey.update(world_survey_params)
      head :no_content
    else
      render json: @world_survey.errors, status: :unprocessable_entity
    end
  end

  # DELETE /world_surveys/1
  # DELETE /world_surveys/1.json
  def destroy
    @world_survey.destroy

    head :no_content
  end

  private

    def set_world_survey
      @world_survey = WorldSurvey.find(params[:id])
    end

    def world_survey_params
      params.require(:world_survey).permit(:system, :commander, :world, :world_type, :terraformable, :gravity, :terrain_difficulty, :notes, :carbon, :iron, :nickel, :phosphorus, :sulphur, :arsenic, :chromium, :germanium, :manganese, :selenium, :vanadium, :zinc, :zirconium, :cadmium, :mercury, :molybdenum, :niobium, :tin, :tungsten, :antimony, :polonium, :ruthenium, :technetium, :tellurium, :yttrium)
    end
end
