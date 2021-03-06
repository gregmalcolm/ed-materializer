module Api
  module V4
    class StarsController < ApplicationController
      include JSONAPI::ActsAsResourceController
      include DataDumpActions

      before_action :authorize_user!, except: [:index, :show, :download, :md5]
      before_action :set_star, only: [:show, :update, :destroy]
      before_action only: [:destroy] {
        authorize_change!(@star.creator,
                          params[:user])
      }

      def index
        @stars = filtered.page(page)
                         .per(per_page)
                         .order(ordering)
        render json: @stars, serializer: PaginatedSerializer,
                             include: params[:include]
      end

      def show
        render json: @star, include: params[:include]
      end

      def create
        @star = Star.new(star_params)

        if @star.save
          render json: @star, status: :created, location: @star
        else
          render json: errors_as_jsonapi(@star.errors), status: :unprocessable_entity
        end
      end

      def update
        @star = Star.find(params[:id])
        validate_system_name

        if @star.errors.blank? && @star.update(star_params)
          head :no_content
        else
          render json: errors_as_jsonapi(@star.errors), status: :unprocessable_entity
        end
      end

      def destroy
        @star.destroy

        head :no_content
      end

      private

      def set_star
        @star = Star.find(params[:id])
      end

      def star_params
        if current_user.role == "user"
          jsonapi_attribute_params[:updater] = current_user.name
        end
        if jsonapi_attribute_params[:system]
          jsonapi_attribute_params[:system_name] = jsonapi_attribute_params.delete(:system)
        end
        sp = params.require(:data)
                   .require(:attributes)
                   .permit(:system_name,
                           :updater,
                           :star,
                           :spectral_class,
                           :spectral_subclass,
                           :solar_mass,
                           :solar_radius,
                           :surface_temp,
                           :star_age,
                           :orbit_period,
                           :arrival_point,
                           :luminosity,
                           :notes,
                           :image_url)
        sp = add_relationship_id(sp, :system)
      end

      def filtered
        Star.by_system_id(params[:system_id])
            .by_system(params[:system])
            .by_updater(params[:updater])
            .by_creator(params[:creator])
            .by_star(params[:star])
            .by_full_star_like(params[:full_star_like])
            .updated_before(params[:updated_before])
            .updated_after(params[:updated_after])
      end

      def per_page
        params[:per_page] || 100
      end

      def validate_system_name
        if star_params[:system_name] &&
        star_params[:system_name].to_s.upcase != @star.system_name.to_s.upcase
          @star.errors.add(:system_name, "cannot be renamed this way")
        end   
      end
    end
  end
end
