module Api
  module V1
    class ChangeLogsController < ApplicationController
      def index
        @change_logs = PaperTrail::Version.page(page).per(per_page).order("created_at desc")
        render json: @change_logs, :root => 'change_logs',
                                   serializer: PaginatedSerializer,
                                   each_serializer: ChangeLogSerializer
      end
    end
  end
end

