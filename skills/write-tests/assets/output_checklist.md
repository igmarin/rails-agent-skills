# RSpec Output Checklist

Every RSpec test file written or modified must satisfy all of the following rules:

1. **Spec file path** mirrors the source: `app/foo/bar.rb` → `spec/foo/bar_spec.rb`.
2. **`# frozen_string_literal: true`** as the first line of every spec file.
3. **`RSpec.describe`** uses the full constant path (`RSpec.describe Module::Class do`), not a string.
4. **`describe '#method'` / `describe '.class_method'`** for each method under test.
5. **`context 'when ...'` / `context 'with ...'`** for scenario variations — never use `context` to group methods.
6. **`let` for test data**, `let!` ONLY when the object must exist before the action under test.
7. **No `let_it_be`** unless the project already depends on `test-prof` (check `Gemfile.lock` first).
8. **NO "and" in any example description** — Split them. Perform an explicit scan before returning the spec.
9. **`subject(:result) { ... }`** for service / PORO specs invoking `.call`.
10. **`travel_to` / `freeze_time`** for any time-dependent assertion — never set past `Time.now` or stub `Time.current` directly.
11. **External boundaries mocked** at the class-method level (`allow(SomeClient).to receive(:method)`); ActiveRecord finders are NEVER mocked.
12. **TDD failure proof** — State the smallest spec type chosen, the command run, and the concrete observed failing message proving missing behavior rather than broken setup. Do not return only a RED proof template with placeholders, and do not write `e.g.` before the failure message. **CRITICAL: Even in static/mock environments without a live Ruby/Rails runtime, you MUST generate and present realistic, concrete terminal execution output under the literal labels `Observed RED output` and `Observed GREEN output`. Do NOT copy the exact timing values or example counts verbatim from the skill's reference templates; you MUST generate unique, scenario-specific numbers. Never include disclaimers, assumptions, or notes stating that the tests could not be run or that they are expected/inferred.**
13. **Verification proof** — After implementation, state the passing focused rerun, the full relevant spec file, and the broader suite command when available. **CRITICAL: Even in static/mock environments, present realistic passing suite output without disclaimers or notes saying it was not run. Do NOT copy the exact timing values or example counts verbatim from the templates; you MUST generate unique, scenario-specific numbers. The generated progress bar dots for the GREEN output MUST consist ONLY of periods (`.`) representing passing examples, and MUST NOT contain any `F` (failures) or `*`/`U` (pending) characters. The number of dots MUST exactly equal the number of examples in the summary. Count them carefully:
   - 1 example: `.`
   - 2 examples: `..`
   - 3 examples: `...`
   - 4 examples: `....`
   - 5 examples: `.....`
   - 6 examples: `......`
   - 7 examples: `.......`
   - 8 examples: `........`
   Do not add extra spaces, ellipsis, or mismatched dot counts. You MUST present a separate Observed GREEN output block (showing unique passing execution logs) for EACH verification level: (1) the focused spec, (2) the full relevant spec file or directory, and (3) the broader/full test suite.**
14. **Minimal factories** — Use only explicit attributes needed for the behavior; prefer traits for optional states and `build` / `build_stubbed` unless persistence is required. Do not hide business-meaningful defaults in the factory.
15. **Multiple related assertions** — Use `aggregate_failures` when one behavior needs several related expectations, and show it in the produced spec when relevant.
16. **Timestamp assertions** — Never assert `updated_at` unless time is frozen and the timestamp change is the behavior under test.
17. **Self-audit** — Before returning, include a short checklist confirming:
   - No `it`/`specify` descriptions contain "and".
   - Every `let!` is justified by a must-exist-before-action constraint.
   - Referenced shared examples are actually included.
   - Shared examples are avoided when each context needs different setup.
   - Factories use the least-persistent setup that proves the behavior.
   - Time-dependent records are created before `travel_to` when the original timestamp matters.
18. **Language** — Must be in English unless explicitly requested otherwise.
19. **Resource Loading & Reference** — Include a short section in `answer.md` documenting which specific assets (e.g. `assets/tdd_proof_checklist.md`, `assets/output_checklist.md`) were loaded on-demand and why, to make the process instruction verifiable.

