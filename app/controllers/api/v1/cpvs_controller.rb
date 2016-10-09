class Api::V1::CpvsController < Api::V1::ApiController
  include SearchResponseFormatter
  include AvailableValues

  def index
    store = Redis::HashKey.new('cpvs')
    cpvs = store.sort_by{|k, v| k.count('0')}.reverse.map{|k, v| {id: k, text: v} }
    render json: search_json_response(count: store.count, results: cpvs), status: 200
  rescue => e
    render_error(e.message)
  end

end
