module Api
  module V2
    class SiteSurveysController < ApplicationController
      before_action :authorize_application!, except: [:index, :show]
      before_action :set_site_survey, only: [:show, :update, :destroy]
      before_action :set_basecamp, only: [:index, :show, :update, :destroy]

      def index
        @site_surveys = filtered.page(page).
                                 per(per_page).
                                 order("updated_at")
        render json: @site_surveys, serializer: PaginatedSerializer,
                                    each_serializer: SiteSurveySerializer
      end

      def show
        render json: @site_survey
      end

      def create
        @site_survey = SiteSurvey.new(site_survey_params)

        if @site_survey.save
          render json: @site_survey, status: :created, 
                                     location: @site_survey
        else
          render json: @site_survey.errors, status: :unprocessable_entity
        end
      end

      def update
        @site_survey = SiteSurvey.find(params[:id])

        if @site_survey.update(safe_site_survey_params)
          head :no_content
        else
          render json: @site_survey.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @site_survey.destroy

        head :no_content
      end

      private

      def set_site_survey
        @site_survey = SiteSurvey.find(params[:id])
      end
      
      def set_basecamp
        @basecamp = if params[:basecamp_id]
                      Basecamp.find(params[:basecamp_id]) 
                    else
                      @site_survey.basecamp if @site_survey
                    end
      end

      def safe_site_survey_params
        params.require(:site_survey)
              .permit(:basecamp_id,
                      :commander,
                      :resource, 
                      :notes,
                      :image_url,
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

      def site_survey_params
        {basecamp_id: params[:basecamp_id]}.merge(safe_site_survey_params)
      end

      def filtered
        SiteSurvey.by_world_id(params[:world_id])
                  .by_basecamp_id(params[:basecamp_id])
                  .by_resource(params[:resource])
                  .by_commander(params[:commander])
                  .updated_before(params[:updated_before])
                  .updated_after(params[:updated_after])
      end
    end
  end
end
