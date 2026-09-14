# Rails Engine Reviewer — Finding Severity Reference

## High-Severity Findings

Flag these first:

- Hidden dependency on a specific host model or constant
- Initializers that mutate global state unsafely or perform writes at boot
- Engine code reaching into host internals without an adapter or configuration seam
- Migrations or setup steps that are implicit, undocumented, or destructive
- Reload-unsafe decorators or patches outside `config.to_prepare`
- No namespace isolation — engine routes or models collide with host
- Test suite passes only with a specific host app; no dummy app or generic integration coverage

## Medium-Severity Findings

- Public API spread across many constants or modules
- Engine routes/controllers not properly namespaced
- Asset, helper, or route naming collisions
- Missing generator coverage or weak install story
- Dummy app present but not used for meaningful integration tests

## Low-Severity Findings

- Inconsistent file layout
- Overly clever metaprogramming where plain objects would be clearer
- README/setup docs that drift from the code

## Common Fixes To Suggest

- Add a configuration object instead of hardcoded host constants
- Move host integration behind adapters or service interfaces
- Add `isolate_namespace`
- Move reload-sensitive hooks into `config.to_prepare`
- Add install generators for migrations or initializer setup
- Add dummy-app request/integration coverage
