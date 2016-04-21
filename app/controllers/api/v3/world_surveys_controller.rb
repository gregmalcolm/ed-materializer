module Api
  module V3
    class WorldSurveysController < ApplicationController
      include DataDumpActions
      
      before_action :authorize_user!, except: [:index, :show, :download, :md5]
      before_action :set_world_survey, only: [:show, :update, :destroy]
      before_action :set_world, only: [:index, :show, :update, :destroy]

      def index
        @world_surveys = filtered.page(page)
                                 .per(per_page)
                                 .order(ordering)
        render json: @world_surveys, serializer: PaginatedSerializer,
                                     include: params[:include]
      end

      def show
        render json: @world_survey, include: params[:include]
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
