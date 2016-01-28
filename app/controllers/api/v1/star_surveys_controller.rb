module Api
  module V1
    class StarSurveysController < ApplicationController
      before_action :authorize_admin!, except: [:index, :show]
      before_action :set_star_survey, only: [:show, :update, :destroy]

      def index
        @star_surveys = filtered.page(page).
                                  per(per_page).
                                  order("updated_at")
        render json: @star_surveys, serializer: PaginatedSerializer,
                                     each_serializer: StarSurveySerializer
      end

      def show
        render json: @star_survey
      end

      def create
        @star_survey = StarSurvey.new(star_survey_params)

        if @star_survey.save
          render json: @star_survey, status: :created, location: @star_survey
        else
          render json: @star_survey.errors, status: :unprocessable_entity
        end
      end

      def update
        @star_survey = StarSurvey.find(params[:id])

        if @star_survey.update(star_survey_params)
          head :no_content
        else
          render json: @star_survey.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @star_survey.destroy

        head :no_content
      end

      private

      def set_star_survey
        @star_survey = StarSurvey.find(params[:id])
      end

      def star_survey_params
        # Blacklisting isn't the most secure way of doing this
        # but the attribute list is long and the security implications
        # are low here
        params.require(:star_survey).
               except!(:id, :updated_at, :created_at).
               permit!
      end

      def filtered
        q = params[:q]
        if q.present?
          StarSurvey.by_system(q[:system]).
                      by_commander(q[:commander]).
                      by_star(q[:star]).
                      updated_before(q[:updated_before]).
                      updated_after(q[:updated_after])
        else
          StarSurvey.all
        end
      end
    end
  end
end
