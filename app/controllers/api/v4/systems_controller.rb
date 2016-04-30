module Api
  module V4
    class SystemsController < ApplicationController
      include JSONAPI::ActsAsResourceController
      include DataDumpActions

      before_action :authorize_user!, except: [:index, :show, :download, :md5]
      before_action :set_system, only: [:show, :update, :destroy]
      before_action only: [:destroy] {
        authorize_change!(@system.creator,
                          params[:user])
      }

      def index
        @systems = filtered.page(page)
                           .per(per_page)
                           .order(ordering)
        render json: @systems, serializer: PaginatedSerializer,
                               include: params[:include]
      end

      def show
        render json: @system, include: params[:include]
      end

      def create
        @system = System.new(system_params)

        if @system.save
          render json: @system, status: :created, location: @system
        else
          render json: errors_as_jsonapi(@system.errors), status: :unprocessable_entity
        end
      end

      def update
        @system = System.find(params[:id])

        if @system.update(system_params)
          head :no_content
        else
          render json: errors_as_jsonapi(@system.errors), status: :unprocessable_entity
        end
      end

      def destroy
        if admin? || !@system.has_children?
          @system.destroy

          head :no_content
        else
          render json: {errors: ["Forbidden because of dependencies."]}, status: 403
        end
      end

      private

      def set_system
        @system = System.find(params[:id])
      end

      def system_params
        if current_user.role == "user"
          jsonapi_attribute_params[:updater] = current_user.name
        end
        params.require(:data)
              .require(:attributes)
              .permit(:system,
                      :updater,
                      :x,
                      :y,
                      :z,
                      :poi_name,
                      :notes,
                      :image_url,
                      :tags)
      end

      def filtered
        System.by_query(params[:q])
              .by_system(params[:system])
              .by_updater(params[:updater])
              .updated_before(params[:updated_before])
              .updated_after(params[:updated_after])
      end
    end
  end
end
