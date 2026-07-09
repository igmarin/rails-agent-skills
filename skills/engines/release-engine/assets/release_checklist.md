# Engine Release Checklist (detailed)

This checklist ensures a safe, repeatable release for a Rails engine gem.

- [ ] Confirm that `assets/release_checklist.md` was loaded and applied to release quality gates
- [ ] Update version constant (lib/<engine>/version.rb) and commit on a release branch
- [ ] Update CHANGELOG.md with user-facing changes (Keep entries short and factual)
- [ ] Run full test suite for the engine and host integration (dummy app)
- [ ] Verify dummy app boots and mounts the engine
- [ ] Ensure migrations are namespaced and reversible; run migration smoke tests in dummy app
- [ ] Build gem locally: `bundle exec rake build` and test `gem install` into a sandboxed project
- [ ] Validate gemspec: required metadata, licenses, files included/excluded
- [ ] Inspect packaged files before publishing: `tar tf <engine>-<version>.gem` for local `.gem` archives (`gem contents` is for installed gems by name)
- [ ] Dry-run push before publishing: `gem push --dry-run <engine>-<version>.gem`
- [ ] Run any packaging CI checks (e.g., RubyGems credentials, signing)
- [ ] Draft GitHub release notes from `assets/release_notes_template.md`
- [ ] Tag release (annotated tag) and push tag to repo
- [ ] Publish gem to Rubygems or private registry; verify package appears
- [ ] Update README with installation/mount instructions and initializer notes
- [ ] Close release PR and merge back to main; ensure changelog and version are correct

Notes: prefer semantic versioning. For breaking changes, follow Major version bump and document migration notes in CHANGELOG.
