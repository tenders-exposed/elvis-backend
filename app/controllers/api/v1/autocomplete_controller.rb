class Api::V1::AutocompleteController < Api::V1::ApiController
  include SearchResponseFormatter

  def actor_names
    results = Supplier.es.client.suggest(
      index: 'autocomplete',
      body: {
        suggestions: {
          text: curated_params[:text],
          completion: {
            field: 'suggest',
            size: curated_params[:max_suggestions]
          }
        }
      }
    )
    suggestions = results.fetch('suggestions', [])[0].fetch('options', [])
    render json: search_json_response(count: suggestions.size,
     results: suggestions.map{|res| res['payload']}), status: 200
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
