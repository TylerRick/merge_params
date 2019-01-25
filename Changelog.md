# Changelog

This project follows [semver 2.0.0](http://semver.org/spec/v2.0.0.html) and the
recommendations of [keepachangelog.com](http://keepachangelog.com/).

## (Unreleased)


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
