# Zeitwerk Notes

Common issues and fixes:

- Ensure module and directory names follow constant naming (MyEngine::Admin => my_engine/admin.rb)
- Avoid autoloading top-level constants in engine initializers; prefer lazy loading inside config.to_prepare
- If using legacy autoloading, prefer adding explicit requires in engine's lib/<engine>.rb
- For Rails < 6.0, document incompatibilities and recommend upgrading or namespacing as fallback

Practical checks:
- Run `bin/rails runner "puts Object.const_defined?('MyEngine')"` in dummy app
- Confirm `Zeitwerk::Loader.eager_load_all` doesn't raise during app boot

References:
- Zeitwerk docs: https://guides.rubyonrails.org/autoloading_and_reloading_constants.html
