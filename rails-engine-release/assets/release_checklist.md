# Engine Release Checklist (detailed)

This checklist ensures a safe, repeatable release for a Rails engine gem.

- [ ] Update version constant (lib/<engine>/version.rb) and commit on a release branch
- [ ] Update CHANGELOG.md with user-facing changes (Keep entries short and factual)
- [ ] Run full test suite for the engine and host integration (dummy app)
- [ ] Run `tessl tile lint` locally to catch packaging issues
- [ ] Verify dummy app boots and mounts the engine
- [ ] Ensure migrations are namespaced and reversible; run migration smoke tests in dummy app
- [ ] Build gem locally: `bundle exec rake build` and test `gem install` into a sandboxed project
- [ ] Validate gemspec: required metadata, licenses, files included/excluded
- [ ] Run any packaging CI checks (e.g., RubyGems credentials, signing)
- [ ] Tag release (annotated tag) and push tag to repo
- [ ] Publish gem to Rubygems or private registry; verify package appears
- [ ] Update README with installation/mount instructions and initializer notes
- [ ] Close release PR and merge back to main; ensure changelog and version are correct

Notes: prefer semantic versioning. For breaking changes, follow Major version bump and document migration notes in CHANGELOG.
