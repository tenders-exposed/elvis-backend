class Api::V1::AutocompleteController < Api::V1::ApiController
  include SearchResponseFormatter

  def actor_names
    request = Search::AutocompleteSearch.new(curated_params[:text],
      curated_params[:max_suggestions])
    render json: search_json_response(count: request.count,
      results: request.search), status: 200
   rescue => e
     render_error(e.message)
  end

  def autocomplete_params
    params.permit(:text, :max_suggestions)
  end

  protected

  def curated_params
    int_suggestions = autocomplete_params.fetch(:max_suggestions, nil).to_i
    {
      text: autocomplete_params.fetch(:text, nil).to_s,
      max_suggestions: int_suggestions > 0 ? int_suggestions : 10
    }
  end
end
