module Api
  module V2
    class WorldsController < ApplicationController
      before_action :authorize_application!, except: [:index, :show]
      before_action :set_world, only: [:show, :update, :destroy]

      def index
        @worlds = filtered.page(page)
                          .per(per_page)
                          .order("updated_at")
        render json: @worlds, serializer: PaginatedSerializer,
                              each_serializer: WorldSerializer
      end

      def show
        render json: @world, serializer: WorldTreeSerializer
      end

      def create
        @world = World.new(world_params)

        if @world.save
          render json: @world, status: :created, location: @world
        else
          render json: @world.errors, status: :unprocessable_entity
        end
      end

      def update
        @world = World.find(params[:id])

        if @world.update(world_params)
          head :no_content
        else
          render json: @world.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @world.destroy

        head :no_content
      end

      private

      def set_world
        @world = World.find(params[:id])
      end

      def world_params
        params.require(:world)
              .permit(:system,
                      :updater,
                      :world,
                      :world_type,
                      :mass,
                      :radius,
                      :gravity,
                      :surface_temp,
                      :surface_pressure,
                      :orbit_period,
                      :rotation_period,
                      :semi_major_axis,
                      :terrain_difficulty,
                      :vulcanism_type,
                      :rock_pct,
                      :metal_pct,
                      :ice_pct,
                      :reserve,
                      :arrival_point,
                      :terraformable,
                      :atmosphere_type,
                      :notes,
                      :image_url)
      end

      def filtered
        World.by_system(params[:system])
             .by_updater(params[:updater])
             .by_world(params[:world])
             .updated_before(params[:updated_before])
             .updated_after(params[:updated_after])
      end
    end
  end
end
