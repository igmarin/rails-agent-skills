# Rails Engine Compatibility Matrix

Purpose: Quick reference mapping of Ruby and Rails versions to supported patterns and required shims.

Supported matrix (example):

- Rails 7.1, Ruby 3.1+: Preferred - Zeitwerk autoloading, config.load_defaults 7.1
- Rails 7.0, Ruby 3.0: Supported - ensure zeitwerk-compatible constant names, avoid eager_load hacks
- Rails 6.1, Ruby 2.7: Legacy - use zeitwerk compatibility flags, add explicit require paths for some initializers
- Rails 5.2, Ruby 2.5: Deprecated - recommend migration plan, guard features behind version checks

Compatibility actions:
- Use feature-detection over version checks where possible (respond_to?, defined?)
- Avoid private API usage that changed between minor Rails versions
- Provide polyfills only when necessary and gate them by version checks
- Add CI matrix entries to verify combinations used by clients

Notes: Keep engine code forward-compatible by following public APIs and avoiding assumptions about initialization order. Document any unavoidable host-app contract requirements in README and engine docs.