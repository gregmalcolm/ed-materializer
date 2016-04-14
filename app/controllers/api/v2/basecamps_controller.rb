module Api
  module V2
    class BasecampsController < ApplicationController
      include DataDumpActions
      
      before_action :authorize_user!, except: [:index, :show, :download, :md5]
      before_action :set_basecamp, only: [:show, :update, :destroy]
      before_action :set_world, only: [:index, :show, :update, :destroy]
      before_action only: [:destroy] {
        authorize_change!(@basecamp.creator,
                          params[:user]) 
      }

      def index
        @basecamps = filtered.page(page)
                             .per(per_page)
                             .order(ordering)
        render json: @basecamps, serializer: PaginatedSerializer,
                                 each_serializer: BasecampSerializer
      end

      def show
        render json: @basecamp, serializer: BasecampTreeSerializer
      end

      def create
        @basecamp = Basecamp.new(basecamp_params)

        if @basecamp.save
          render json: @basecamp, status: :created, 
                                  location: @world
        else
          render json: @basecamp.errors, status: :unprocessable_entity
        end
      end

      def update
        @basecamp = Basecamp.find(params[:id])

        if @basecamp.update(basecamp_params)
          head :no_content
        else
          render json: @basecamp.errors, status: :unprocessable_entity
        end
      end
      
      def destroy
        @basecamp.destroy
        
        head :no_content
      end

      private

      def set_basecamp
        @basecamp = Basecamp.find(params[:id])
      end
      
      def set_world
        @world = if params[:world_id]
                      World.find(params[:world_id]) 
                    else
                      @basecamp.world if @basecamp
                    end
      end

      def basecamp_params
        { world_id: params[:world_id] }.merge(safe_basecamp_params)
      end
      
      def safe_basecamp_params
        if current_user.role == "user"
          params[:basecamp][:updater] = current_user.name
        end
        params.require(:basecamp)
              .permit(:world_id,
                      :updater,
                      :name,
                      :description,
                      :landing_zone_terrain,
                      :terrain_hue_1,
                      :terrain_hue_2,
                      :terrain_hue_3,
                      :landing_zone_lat,
                      :landing_zone_lon,
                      :notes,
                      :image_url)
      end


      def filtered
        Basecamp.by_world_id(params[:world_id])
                .by_name(params[:name])
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
