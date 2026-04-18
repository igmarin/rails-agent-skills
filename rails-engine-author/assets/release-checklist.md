# Engine Release Checklist

- [ ] Bump version in engine's version.rb
- [ ] Update CHANGELOG.md with user-facing changes
- [ ] Run full test suite for engine and host integration
- [ ] Verify dummy app boots and mounts the engine
- [ ] Ensure migrations are namespaced and reversible
- [ ] Build gem locally and smoke-test gem install
- [ ] Update README with mount/initializer instructions
- [ ] Tag release and push release notes
- [ ] Publish gem to Rubygems (or internal registry)

Use `bundle exec rake build` and `gem push` as appropriate.
