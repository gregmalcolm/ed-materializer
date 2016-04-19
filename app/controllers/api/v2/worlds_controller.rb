module Api
  module V2
    class WorldsController < ApplicationController
      include DataDumpActions

      before_action :authorize_user!, except: [:index, :show, :download, :md5]
      before_action :set_world, only: [:show, :update, :destroy]
      before_action only: [:destroy] {
        authorize_change!(@world.creator,
                          params[:user]) }

      def index
        @worlds = filtered.page(page)
                          .per(per_page)
                          .order(ordering)
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
        validate_system_name

        if @world.errors.blank? && @world.update(world_params)
          head :no_content
        else
          render json: @world.errors, status: :unprocessable_entity
        end
      end

      def destroy
        if admin? || !@world.has_children?
          @world.destroy
          head :no_content
        else
          render json: {errors: ["Forbidden because of dependencies."]}, status: 403
        end
      end

      private

      def set_world
        @world = World.find(params[:id])
      end

      def world_params
        if current_user.role == "user"
          params[:world][:updater] = current_user.name
        end
        if params[:world] && params[:world][:system]
          params[:world][:system_name] = params[:world].delete(:system)
        end
        params.require(:world)
              .permit(:system_name,
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
        World.by_system_id(params[:system_id])
             .by_system(params[:system])
             .by_updater(params[:updater])
             .by_world(params[:world])
             .updated_before(params[:updated_before])
             .updated_after(params[:updated_after])
      end

      def per_page
        params[:per_page] || 100
      end

      def validate_system_name
        if world_params[:system_name] &&
        world_params[:system_name].to_s.upcase != @world.system_name.to_s.upcase
          @world.errors.add(:system_name, "cannot be renamed this way")
        end   
      end
    end
  end
end
