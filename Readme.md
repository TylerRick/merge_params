# MergeParams

[![Gem Version](https://badge.fury.io/rb/merge_params.svg)](https://badge.fury.io/rb/merge_params)

## Why do we need it?

Have you ever wanted to take the current route and change just one parameter in the route to
generate a new route?

For example, maybe you've tried to do something like this:

```ruby
  redirect_to url_for(params.merge(thing_id: thing.id));
```

or this:

```ruby
  link_to 'Download as CSV', params.merge(format: :csv)
```

If you have tried that, and you are on Rails 5.0 or later, then you have probably run into this
error:

  Attempting to generate a URL from non-sanitized request parameters! An attacker can
  inject malicious data into the generated URL, such as changing the host.  Whitelist and sanitize
  passed parameters to be secure.

(See also: https://github.com/rails/rails/issues/26289)

## How do I use it?

Anywhere you would be tempted to do `params.merge(hash)`, just replace with `merge_params(hash)` or `merge_url_for(hash)`. For example:

```ruby
  link_to 'Download as CSV', merge_params(format: :csv)
```

```ruby
  redirect_to merge_url_for(thing_id: thing.id);
```

## Is it guaranteed to be safe?

No. While a best effort has been made to ensure unsafe params are not used to generate a URL, we may
have overlooked something. Please review the code and the tests (coming soon) and open an issue if
you find any security holes in this approach.

## Other helpers

Unlike `url_for_merge`, which tries to generate a route from the given params, sometimes you just
want to add the given params to the "end" of the URL as part of the query string:

```ruby
add_params(key: 'value')
# => "/current_path?key=value

add_params({key: 'value'}, '/other_url')
# => "/other_url?key=value
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'merge_params'
```

Add this line to your `ApplicationController` (or whichever controller you want to have the
helpers):

```ruby
  include MergeParams::Helpers
```

The helpers will be also be added with `helper_method` so that they are available for use in view
templates as well.

## Similar projects

- [uri_query_merger](https://libraries.io/github/jordanmaguire/uri_query_merger)

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/TylerRick/merge_params.
