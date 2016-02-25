module Api
  module V2
    class StarsController < ApplicationController
      before_action :authorize_admin!, except: [:index, :show]
      before_action :set_star, only: [:show, :update, :destroy]

      def index
        @stars = filtered.page(page).
                               per(per_page).
                               order("updated_at")
        render json: @stars, serializer: PaginatedSerializer,
                             each_serializer: StarSerializer
      end

      def show
        render json: @star
      end

      def create
        @star = Star.new(star_params)

        if @star.save
          render json: @star, status: :created, location: @star
        else
          render json: @star.errors, status: :unprocessable_entity
        end
      end

      def update
        @star = Star.find(params[:id])

        if @star.update(star_params)
          head :no_content
        else
          render json: @star.errors, status: :unprocessable_entity
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
        # Blacklisting isn't the most secure way of doing this
        # but the attribute list is long and the security implications
        # are low here
        params.require(:star)
              .permit(:system,
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
                      :notes)
      end

      def filtered
        Star.by_system(params[:system])
            .by_updater(params[:updater])
            .by_star(params[:star])
            .updated_before(params[:updated_before])
            .updated_after(params[:updated_after])
      end
    end
  end
end
