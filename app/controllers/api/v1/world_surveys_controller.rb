module Api
  module V1
    class WorldSurveysController < ApplicationController
      before_action :set_world_survey, only: [:show, :update, :destroy]

      def index
        @world_surveys = filtered.page(page).
                                  per(per_page)
        render json: @world_surveys, serializer: PaginatedSerializer,
                                     each_serializer: WorldSurveySerializer
      end

      def show
        render json: @world_survey
      end

      def create
        @world_survey = WorldSurvey.new(world_survey_params)

        if @world_survey.save
          render json: @world_survey, status: :created, location: @world_survey
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

      def world_survey_params
        # Blacklisting isn't the most secure way of doing this
        # but the attribute list is long and the security implications
        # are low here
        params.require(:world_survey).
               except!(:id, :updated_at, :created_at).
               permit!
      end

      def filtered
        q = params[:q]
        if q.present?
          WorldSurvey.by_system(q[:system]).
                      by_commander(q[:commander]).
                      by_world(q[:world]).
                      updated_before(q[:updated_before]).
                      updated_after(q[:updated_after])
        else
          WorldSurvey.all
        end
      end
    end
  end
end
