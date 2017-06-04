class Api::V1::PerformanceStatsController < Api::V1::ApiController
  before_action :authenticate_user!

  def create
    @performance_stats = PerformanceStats.create(performance_stats_params)
    if @performance_stats.save!
      render json: @performance_stats,  status: 201
    else
      render json: { errors: @performance_stats.errors }, status: 422
    end
  end

  def performance_stats_params
    params.require(:performance_stats).permit(:version, :created_at,
      network: [:id, :contracts, :nodes, :edges],
      client: [
        os: [:name, :version],
        browser: [:name, :version],
        resolution: [:screen, :window],
        device: [:type, :name]
      ],
      performance: [
        cpvs: [:count, :loadTime, :treeRender],
        network: [:save, :iterationsTime, :iterationsCount, :renderTime]
      ]
    )
  end
end
