module Api
  module V2
    class WorldsController < ApplicationController
      before_action :authorize_admin!, except: [:index, :show]
      before_action :set_world, only: [:show, :update, :destroy]

      def index
        @worlds = filtered.page(page)
                          .per(per_page)
                          .order("updated_at")
        render json: @worlds, serializer: PaginatedSerializer,
                              each_serializer: WorldSerializer
      end

      def show
        render json: @world
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
        # Blacklisting isn't the most secure way of doing this
        # but the attribute list is long and the security implications
        # are low here
        params.require(:world).
               except!(:id, :updated_at, :created_at).
               permit!
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
