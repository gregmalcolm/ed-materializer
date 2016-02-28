module Api
  module V2
    class SiteSurveysController < ApplicationController
      before_action :authorize_admin!, except: [:index, :show]
      before_action :set_site_survey, only: [:show, :update, :destroy]
      before_action :set_world, only: [:show, :update, :destroy]
      before_action :set_basecamp, only: [:show, :update, :destroy]

      def index
        set_world if params[:world_id]
        set_basecamp if params[:basecamp_id]
        @site_surveys = filtered.page(page).
                                 per(per_page).
                                 order("updated_at")
        render json: @site_surveys, serializer: PaginatedSerializer,
                                    each_serializer: SiteSurveySerializer
      end

      #def show
        #render json: @site_survey
      #end

      #def create
        #@site_survey = SiteSurvey.new(new_site_survey_params)

        #if @site_survey.save
          #render json: @site_survey, status: :created, 
                                  #location: world_basecamp_site_surveys_url(
                                              #params[:world_id], params[:basecamp_id])
        #else
          #render json: @site_survey.errors, status: :unprocessable_entity
        #end
      #end

      #def update
        #@site_survey = SiteSurvey.find(params[:id])

        #if @site_survey.update(site_survey_params)
          #head :no_content
        #else
          #render json: @site_survey.errors, status: :unprocessable_entity
        #end
      #end

      #def destroy
        #@site_survey.destroy

        #head :no_content
      #end

      private

      def set_site_survey
        @site_survey = SiteSurvey.find(params[:id])
      end
      
      def set_world
        @world = World.find(params[:world_id])
      end
      
      def set_basecamp
        @basecamp = Basecamp.find(params[:basecamp_id])
      end

      def site_survey_params
        params.require(:basecamp)
              .permit(:basecamp_id,
                      :commander,
                      :resource, 
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

      def new_site_survey_params
        site_survey_params.merge(world_id: params[:world_id],
                                 basecamp_id: params[:basecamp_id])
      end

      def filtered
        SiteSurvey.by_resource(params[:resource])
                  .by_commander(params[:commander])
                  .updated_before(params[:updated_before])
                  .updated_after(params[:updated_after])
      end
    end
  end
end
