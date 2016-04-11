module Api
  module V2
    class WorldSurveysController < ApplicationController
      include DataDumpActions
      
      before_action :authorize_user!, except: [:index, :show, :download, :md5]
      before_action :set_world_survey, only: [:show, :update, :destroy]
      before_action :set_world, only: [:index, :show, :update, :destroy]
      before_action only: [:destroy] {
        authorize_change!(@world_survey.creator,
                          params[:user]) 
      }

      def index
        @world_surveys = filtered.page(page)
                                 .per(per_page)
                                 .order(ordering)
        render json: @world_surveys, serializer: PaginatedSerializer,
                                     each_serializer: WorldSurveySerializer
      end

      def show
        render json: @world_survey
      end

      def create
        @world_survey = WorldSurvey.new(world_survey_params)

        if @world_survey.save
          render json: @world_survey, status: :created, 
                                  location: @world
        else
          render json: @world_survey.errors, status: :unprocessable_entity
        end
      end

      def update
        @world_survey = WorldSurvey.find(params[:id])

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
        @world_survey = WorldSurvey.find(params[:id])
      end
      
      def set_world
        @world = if params[:world_id]
                      World.find(params[:world_id]) 
                    else
                      @world_survey.world if @world_survey
                    end
      end

      def safe_world_survey_params
        if current_user.role == "user"
          params[:world_survey][:updater] = current_user.name
        end
        params.require(:world_survey)
              .permit(:world_id,
                      :updater,
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

      def world_survey_params
        { world_id: params[:world_id] }.merge(safe_world_survey_params)
      end

      def filtered
        WorldSurvey.by_world_id(params[:world_id])
                   .by_updater(params[:updater])
                   .updated_before(params[:updated_before])
                   .updated_after(params[:updated_after])
      end

      def per_page
        params[:per_page] || 100
      end
    end
  end
end
