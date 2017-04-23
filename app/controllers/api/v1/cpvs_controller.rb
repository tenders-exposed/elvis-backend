class Api::V1::CpvsController < Api::V1::ApiController
  include SearchResponseFormatter
  include AvailableValues

  def index
    store = Redis::HashKey.new('cpvs', marshal: true)
    cpvs = store.sort_by{|cpv, cpv_obj| cpv_obj['number_digits']}.map do |cpv, cpv_obj|
      cpv_obj['id'] = cpv_obj.delete('code')
      cpv_obj
    end
    render json: search_json_response(count: store.count, results: cpvs), status: 200
  rescue => e
    render_error(e.message)
  end

end
