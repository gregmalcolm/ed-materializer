module Api
  module V2
    class WorldSurveysController < ApplicationController
      before_action :authorize_admin!, except: [:index, :show]
      before_action :set_world_survey, only: [:show, :update, :destroy]

      def index
        @world_surveys = filtered.page(page).
                                  per(per_page).
                                  order("updated_at")
        render json: @world_surveys, serializer: PaginatedSerializer,
                                     each_serializer: ::V2::WorldSurveyV1Serializer,
                                     root: "world_surveys"
      end

      def show
        render json: @world_survey, serializer: ::V2::WorldSurveyV1Serializer,
                                    root: "world_survey"
      end

      def create
        @world_survey = WorldSurveyV1.new(world_survey_params)

        if @world_survey.save
          render json: @world_survey, serializer: ::V2::WorldSurveyV1Serializer,
                                      status: :created, 
                                      location: world_survey_url(@world_survey),
                                      root: "world_survey"
        else
          render json: @world_survey.errors, status: :unprocessable_entity
        end
      end

      def update
        @world_survey = WorldSurveyV1.find(params[:id])

        if @world_survey.update(world_survey_params)
          head :no_content
        else
          render json: @world_survey.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @world_survey.destroy

        head :no_content
      end

      private

      def set_world_survey
        @world_survey = WorldSurveyV1.find(params[:id])
      end

      def world_survey_params
        params.require(:world_survey)
              .permit(:system,
                      :commander,
                      :world,
                      :notes,
                      :carbon,
                      :iron,
                      :nickel,
                      :phosphorus,
                      :sulphur,
                      :arsenic,
                      :chromium,
                      :germanium,
                      :manganese,
                      :selenium,
                      :vanadium,
                      :zinc,
                      :zirconium,
                      :cadmium,
                      :mercury,
                      :molybdenum,
                      :niobium,
                      :tin,
                      :tungsten,
                      :antimony,
                      :polonium,
                      :ruthenium,
                      :technetium,
                      :tellurium,
                      :yttrium)
      end

      def filtered
        WorldSurveyV1.by_system(params[:system])
                   .by_commander(params[:commander])
                   .by_world(params[:world])
                   .updated_before(params[:updated_before])
                   .updated_after(params[:updated_after])
      end
    end
  end
end
