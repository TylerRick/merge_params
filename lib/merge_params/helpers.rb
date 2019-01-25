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

  # Easily extract just certain param keys.
  #
  # Can't use permit().to_h — for example,
  #    params.permit(:page, :per_page, :filters).to_h
  # or you'll get an error about whatever other unrelated keys happen to be set:
  #   found unpermitted parameters: :utf8, :commit, :company_id
  #
  # One good solution might be to have a permitted_params method defined with *all* of your
  # permitted params for this controller, and then you could make other methods that fetch subsets
  # of those params using slice. But if you don't want to do that, this slice_params helper is
  # another good option.
  #
  # Other options include:
  # - You *could* add those unrelated keys to always_permitted_parameters ... but that only works if
  #   all of them should be permitted *everywhere* — there are probably controller-specific params
  #   present that are permitted for this controller.
  # - You could also change action_on_unpermitted_parameters — but unfortunately, there's no way to
  #   pass a temporary override value for that directly to permit, so the only option is to change it
  #   temporarily globally, which is inconvenient and not thread-safe.
  def slice_params(*keys)
    params_for_url_for.slice(*keys)
  end

  # Safely merges the given params with the params from the current request, then generates a route
  # from the merged params.
  # You can remove a key by passing nil as the value, for example {key: nil}.
  def merge_url_for(new_params = {})
    url = url_for(merge_params(new_params))

    # Now pass along in the *query string* any params that we couldn't pass to url_for because they
    # were reserved options.
    query_params_already_added = parse_nested_query(URI(url).query || '')
    # Some params from new_params (like company_id) that we pass in may be recognized by a route and
    # therefore no longer be query params. We use recognize_path to find those params that ended up
    # as route params instead of query_params but are nonetheless aready added to the url.
    params_already_added = Rails.application.routes.recognize_path(url).merge(query_params_already_added)
    keys_already_added = params_already_added.keys
    # Allow keys that are currently in query_params to be deleted by setting their value to nil in
    # new_params.
    keys_to_delete = new_params.select {|k,v| v.nil?}.keys
    query_params_to_add = query_params.except(*keys_already_added + keys_to_delete)
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
    uri.query = Rack::Utils.build_nested_query(params) if params.present?
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
