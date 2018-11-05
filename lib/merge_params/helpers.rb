require 'uri'

module MergeParams::Helpers
  extend ActiveSupport::Concern

  # request.parameters but with symbolized keys.
  def request_params
    request.parameters.symbolize_keys
  end

  # request.parameters (which also includes POST params) but with only those keys that would
  # normally be passed in a query string (without :controller, :action, :format) and with symbolized
  # keys.
  def query_params_from_request_params
    request.parameters.symbolize_keys.
      except(*request.path_parameters.symbolize_keys.keys)
  end

  # Returns a hash of params from the query string (https://en.wikipedia.org/wiki/Query_string),
  # with symbolized keys.
  def query_params
    request.query_parameters.symbolize_keys
  end

  # Params that can safely be passed to url_for to build a route. (Used by merge_url_for.)
  #
  # We exclude RESERVED_OPTIONS such as :host because such options should only come from your app
  # code. Allowing :host to be set via query params, for example, means a bad actor could cause
  # links that go to a different site entirely:
  #
  # # Request for /things?host=somehackingsite.ru
  # url_for(params) => "http://somehackingsite.ru/things"
  #
  # Similarly, the :controller and :action keys of `params` *never* come from the query string, but
  # from `path_parameters`. (TODO: So why not just use params.except(...)?)
  #
  # TODO: Why not allow :format from params? To force people to use .:format? But doesn't that also
  # come through as params?
  #
  # (And we don't even need to pass the path_parameters on to url_for because url_for already
  # includes those (from :_recall)
  #
  def params_for_url_for
    params.to_unsafe_h.symbolize_keys.except(
      *ActionDispatch::Routing::RouteSet::RESERVED_OPTIONS,
      :controller,
      :action,
      :format
    )
  end

  # Safely merges the given params with the params from the current request
  def merge_params(new_params = {})
    params_for_url_for.merge(new_params)
  end

  # Safely merges the given params with the params from the current request, then generates a route
  # from the merged params.
  def merge_url_for(new_params = {})
    url = url_for(merge_params(new_params))

    # Now pass along in the *query string* any params that we couldn't pass to url_for because they
    # were reserved options.
    query_params_already_added = parse_nested_query(URI(url).query || '')
    query_params_to_add = query_params.except(*query_params_already_added.keys)
    add_params(query_params_to_add, url)
  end

  # Adds params to the query string
  # (Unlike url_for_merge, which tries to generate a route from the params.)
  # TODO: Should URL be first like https://libraries.io/github/jordanmaguire/uri_query_merger ?
  #   UriQueryMerger.new("http://www.google.com?other=1", {jordan: "rules"}).merge
  # Can we make it work that way when a URL is supplied buth otherwise let the params be the first
  # and only argument (to optimize for that more common use case)?
  def add_params(params = {}, url = request.fullpath)
    uri = URI(url)
    params    = parse_nested_query(uri.query || '').merge(params)
    uri.query = Rack::Utils.build_nested_query(params)
    uri.to_s
  end

  included do
    helper_method(
      :request_params,
      :params_for_url_for,
      :merge_params,
      :merge_url_for,
      :add_params
    ) if respond_to?(:helper_method)
  end

private

  def parse_nested_query(query)
    Rack::Utils.parse_nested_query(query || '').symbolize_keys
  end
end