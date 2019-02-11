# Changelog

This project follows [semver 2.0.0](http://semver.org/spec/v2.0.0.html) and the
recommendations of [keepachangelog.com](http://keepachangelog.com/).

## (Unreleased)

## 0.4.2 (2019-02-10)
- Fix `merge_url_for` to not pass on reserved options like only_path (which were only intended for
  consumption by `url_for`) to `add_params`. It was adding it to the end of the URL, like
  `only_path=true`.

## 0.4.1 (2019-02-08)
- Fix issue with merge_params not merging nested hashes as expected (changed to
  use `deep_merge` instead of `merge`)

## 0.4.0 (2019-02-07)

### Added/Changed
- Better support for nested hashes: Using `deep_symbolize_keys` instead of `symbolize_keys`.
- Allow keys in nested hashes to be deleted by setting their value to nil
- Add `params_from_url(url)` helper
- Allow a hash to be passed as an argument to `params_for_url_for`
- Add dependency on `facets` gem

## 0.3.0 (2019-01-24)

### Fixed
- Fix `merge_url_for` to not try to add a param as a query param if it's been recognized as a route
  param (part of the route path). We don't want the same param to be passed both via the route path
  *and* the query string.

### Added
- `merge_url_for`: Allow keys that are currently in `query_params` to be deleted by setting their
  value to `nil`.


## 0.2.0 (2018-12-05)

### Fixed
- Fix `add_params` to not inadvertently add a '?' to the end of the URI if there are no params to add

### Added
- Add `slice_params` helper


## 0.1.0 (2018-11-16)

Initial release
