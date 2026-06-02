# Skill Description Strategy

*Optimizing `description` metadata for Tessl baseline eval scores.*

## The Bottleneck

The Tessl eval task prompt includes only the **first sentence** of the skill's `description` metadata. The function `sentence_from_description` splits on `/(?<=[.!?])\s+/` — everything after the first `. ` (or `!` / `?` + space) is invisible to the agent in baseline mode.

The first sentence is the **only signal** the agent receives about the skill's specific conventions. The rest of the description, the SKILL.md body, assets, and examples are all invisible until the agent loads the skill explicitly.

## Tessl CLI (Plugin Mode)

Since the migration from tiles to plugins:

```bash
# 1. Rename scenarios directory (required for plugin auto-discovery)
mv tessl-evals evals

# 2. Run the eval on the plugin (auto-detects evals/ directory)
tessl eval run .

# 3. View results — note baseline scores <80%
tessl eval view --last

# 4. Get detailed instruction-level breakdown
tessl eval view <eval-run-id> --json

# 5. Check what the agent actually sees in the task prompt
cat evals/<skill-name>/scenario-0/task.md

# 6. Compare against the description frontmatter
head -15 skills/<category>/<skill-name>/SKILL.md
```

**Important: The scenarios directory MUST be named `evals/`** — the Tessl CLI in plugin mode looks for `evals/` inside the plugin's directory. Other names (like `tessl-evals/`) will not be discovered. See [Evaluate skill quality using scenarios](https://docs.tessl.io/improving-your-skills/evaluate-skill-quality-using-scenarios.md#step-4-run-the-evaluation) for details.

Skills without local `evals/` scenarios get **auto-generated evals** by Tessl. These auto-generated evals extract behavioral rules from the SKILL.md body and test the agent solely on the first sentence. For these skills, an effective first sentence is even more critical — there is no custom scenario to provide additional context.

## Persona Skills (`type: persona`)

Persona skills (orchestrating multi-phase workflows) are especially vulnerable to low baseline scores. Their SKILL.md bodies contain hard gates, phase ordering rules, error recovery procedures, and gate patterns — all of which the generic Tessl eval tests against, but none of which fit easily in a first sentence.

**Strategy for personas:** Lead with hard gates and non-negotiable rules. What the persona *does* is implicit from its name — the first sentence must encode *how* it enforces quality:

```
Bad:  "Orchestrates the full delivery pipeline from idea to retrospective..."
Good: "Full delivery pipeline with hard gates at PRD approval (explicit sign-off, loop-back on needs-revision), sprint commitment (capacity ≤80% with goal), and retrospective (every what-didn't needs action item); phases scope→plan→prioritize→sprint→execute→retrospect, on timeout resume from last completed phase."
```

## Rules

### Rule 1: Pack all critical rules into the first sentence

Use one long sentence with commas, colons, and em dashes — no periods until the very end of the critical content:

```yaml
description: >
  Use when creating service classes with `self.call` entry point,
  `{success:, response:}` response contract, spec at `spec/services/...`,
  `UPPER_SNAKE_CASE` error constants, mandatory module README, and test BEFORE
  implementation. Covers 4 core patterns...
```

Everything up to the first `. ` becomes the task prompt. Everything after is invisible in baseline mode.

### Rule 2: Avoid `...` followed by whitespace

Backtick expressions like `{ ... } }` contain `...` followed by a space. The regex `(?<=[.!?])\s+` splits at the third `.` + space, truncating the first sentence mid-expression.

**Bad:** `{ success: true/false, response: { ... } }` → splits after `...`

**Good:** `{success: true/false, response: {...}}` → no space after `...`

Same rule applies anywhere three dots appear: `"..."` is fine (third dot followed by `"` not space), but `"..." }` triggers a split (third dot followed by ` }`).

Check for this in the generated task prompt — if the sentence is truncated at `...`, fix the space.

### Rule 3: Use `—` (em dash) or `,` instead of periods for pauses

A period ends the first sentence. Use alternatives:

**Bad:**
```
Create service classes with .call pattern. Spec at spec/services/.
```

**Good:**
```
Create service classes with .call pattern, spec at spec/services/
```

### Rule 4: Put trigger words after the first sentence

Trigger words are for skill selection — they don't need to be in the task prompt. Place them after the first period where they're available for selection but don't consume first-sentence space:

```
description: >
  Use when creating service classes with .call pattern, spec at
  spec/services/... MUST write test BEFORE implementation.
  Trigger words: service object, .call pattern, services.
```

### Rule 5: Watch for `?` in method names

The regex splits on `?` followed by whitespace. `should_calculate?` is fine (`?=` no space) but `should_calculate? ` with a trailing space would split. Avoid trailing spaces after question marks in the first sentence.

## Workflow: Fixing a Low-Scoring Skill

### Step 1: Read the eval results

```bash
tessl eval view --last
```

Note which skills score <80% baseline. For detailed instruction-level analysis:

```bash
tessl eval view <eval-run-id> --json
```

The JSON output contains a `rubric.checklist` array with each instruction's `name`, `description`, and `max_score` — this shows exactly what rules the agent was expected to follow.

### Step 2: Map instructions to description content

- Does the instruction test content that lives in the SKILL.md body?
- Can that rule be summarized in the first sentence?
- Is it a concrete example that's fundamentally invisible? (Accept lower baseline)

### Step 3: Edit the description

Edit the `description` field in `skills/<category>/<skill>/SKILL.md`:

1. Move critical rules before the first `. ` — use commas/em dashes instead
2. Eliminate `... ` (three dots followed by space) inside backticks
3. Keep the first sentence as one long sentence ending at the first period

For persona skills, lead with hard gates and non-negotiable behavioral rules rather than describing what the persona does.

### Step 4: Verify

```bash
# Check what the agent will see
cat evals/<skill>/task.md  # for skills with flat evals/
cat evals/<skill>/scenario-0/task.md  # for skills with nested evals/

# Confirm first sentence boundary
head -15 skills/<category>/<skill>/SKILL.md
```

**Note:** The `task.md` file is cached from the last `tessl eval run` or `tessl scenario generate`. If you change the description, either regenerate scenarios with `tessl scenario generate .` or delete the cached `task.md` and re-run the eval to pick up the new description.

### Step 5: Run eval

```bash
# Plugin mode (auto-discovers evals/ and all skills)
tessl eval run .

# Codebase mode (explicit scenario path)
tessl eval run ./evals/

tessl eval view --last
```

Check if the specific low-scoring instruction improved.

### Step 6: Check project linkage

If eval scores are 0% for all skills (even previously good ones), run:

```bash
tessl project repair
```

A missing or broken Tessl project link can cause the scorer to fail silently. Verify `tessl.json` has a valid project link.

### Step 7: Try a different agent model

If baseline scores are 0% systemically while with-context scores are normal, the agent model may have a baseline-mode bug. Retry with a different model:

```bash
tessl eval run . --agent "claude:claude-sonnet-4-6"
tessl eval run . --agent "claude:claude-opus-4-6"
```

Known issue: `claude:glm-5.1` may produce 0% baseline scores due to a solver compatibility issue in baseline mode.

## The Ceiling

Some instructions test specific examples or content from the SKILL.md body that cannot fit in a first sentence:

- Worked examples with specific domain values (e.g., `Order must never transition from cancelled back to active`)
- Patterns-to-avoid lists with specific class names
- Extended reference loading instructions

These are fundamentally invisible in baseline mode. A first sentence can hint at them (e.g., "document each concept with its invariant example and patterns to avoid") but cannot embed the full content. Expect baseline scores of 60-70% for these.

For persona skills specifically, auto-generated evals test the hard gates and patterns embedded in the SKILL.md body. These rules *can* fit in the first sentence because they are names and boolean conditions (e.g., "do not proceed without approval", "loop back on needs revision", "every risk must have an owner"). The ceiling for personas is higher (80-90%) if the first sentence captures the essential gates.

## Measurement

### v1.0.0 (ruby-core-skills, initial)

**54% baseline avg** — before any first-sentence optimization.

### v1.1.0 (ruby-core-skills, after optimization)

**87% baseline avg** — after applying Rules 1-5.

| Skill | Before | After | Delta |
|-------|--------|-------|-------|
| refactor-process | 33% | 100% | +67 |
| generate-tdd-tasks | 20% | 97% | +77 |
| skill-router | 50% | 98% | +48 |
| integrate-api-client | 37% | 93% | +56 |
| create-service-object | 19% | 85% | +66 |
| implement-calculator-pattern | 41% | 82% | +41 |
| security-review-process | 52% | 84% | +32 |
| review-domain-boundaries | 52% | 74% | +22 |
| respond-to-review | 58% | 82% | +24 |
| tdd-process | 67% | 91% | +24 |
| write-yard-docs | 77% | 89% | +12 |
| test-planning-process | 75% | 88% | +13 |

### v1.2.0 (agnostic-planning-skills, after optimization)

**93% baseline avg** (up from 81%) — after applying persona hard-gate strategy and tightening atomic skill first sentences. Validated with `claude:claude-sonnet-4-6` (note: `claude:glm-5.1` has a known baseline-mode incompatibility producing false 0% scores).

| Skill | Before | After | Delta | Fix applied |
|-------|--------|-------|-------|-------------|
| Identify Risks | 76% | **94%** | **+18** | Lead with "do NOT fabricate — every risk MUST reference evidence, verify ratings" |
| Plan Tickets | 81% | 76% | -5 σ | Added don't-re-plan + readiness checklist; instruction-4 remains borderline |
| Delivery Lead* | 19% | N/A | — | Persona: packed 3 hard gates + phase ordering into first sentence |
| Product Owner* | 62% | N/A | — | Persona: packed 4 hard gates into first sentence |
| Project Manager* | 37% | N/A | — | Persona: packed 3 hard gates + constraints into first sentence |

*\*Persona skills use Tessl auto-generated evals (no local `evals/` scenarios) — testing requires `tessl scenario generate` first.*

### v2.0.0 (hanakai-yaku, after migration + optimization)

**91% baseline avg** (35 atomic skills) — tested after flatten-agents-into-personas migration, before per-skill description optimization.

| Skill | Score | Note |
|-------|-------|------|
| Inject Dependencies | 100% | Perfect first-sentence packing |
| Create App | 100% | CLI commands packed tightly |
| Create View | 100% | Clear exposure + template rules |
| Review Code | 100% | 10-line rule + DI audit clear |
| Write Rom Spec | 100% | Transaction rollback + tuple error |
| Run Development | 85% | Multi-command workflow hard to compress |
| Create Validation Contract | 82% | Dry::Validation DSL reference heavy |
| Configure Providers | 82% | Lifecycle phases need examples |
| Create Action | 80% | Many optional params |
| Define Entity | 80% | dry-types schema details |
| Implement DI | 80% | Borderline — acceptable |
| **Extract Slice** | **79%** | Progressive disclosure rule (#6) hard to fit in first sentence |
| **Write Request Spec** | **67%** | "Confirm fails before implement" + "use create-action" rule scored low |
| **Baseline avg** | **91%** | No skills below 67%; with-context avg not yet measured |

**Lesson unique to hanakai-yaku:** The `write-request-spec` skill has a TDD gate ("confirm the spec fails because the route is unimplemented") that the Tessl eval tests as instruction-2, but agents tend to skip it in baseline mode. The fix was to lead with `"Write failing RSpec request spec first then use create-action to implement"`. The eval re-run requires `tessl scenario generate .` first (or targeted re-generation) since cached task.md files don't reflect description changes.

### Key Lessons

1. **Leading with the most critical constraint produces the biggest gains.** Identify Risks jumped +18 points by putting "do NOT fabricate risks, every risk MUST reference evidence" at the very start.

2. **Persona skills need hard gates first, not descriptions of what they do.** The delivery-lead went from describing artifacts to encoding approval rules.

3. **Some rules resist compression.** Plan Tickets instruction-4 ("do not re-plan if a plan already exists") is a nuanced conditional that can't be packed into a first sentence without making it unreadable. Accepting 70-75% for these is realistic.

4. **The with-context ceiling is 95-100%.** If with-context scores are consistently lower than 90%, the SKILL.md body needs improvement, not just the description.

## Cross-Repo Applicability

This strategy applies to any repo with Tessl evals that use `sentence_from_description` (the standard Tessl eval generator):

| Repo | Description | Skills | Plugin mode |
|------|-------------|--------|-------------|
| ruby-core-skills | Ruby + process skills | 16 | `"skills": "./skills/"` |
| agnostic-planning-skills | PM + planning skills | 11 + 4 personas | `"skills": "./skills/"` |
| rails-agent-skills | Rails-specific skills | 28 + 9 agents (not yet migrated) | `"skills": "./skills/"` |
| hanakai-yaku | Hanami/dry-rb/ROM skills | 35 + 10 personas | `"skills": "./skills/"` |

### Migration checklist for each repo:

- [ ] Rename `tessl-evals/` → `evals/` (or create a symlink)
- [ ] Update `.tessl-plugin/plugin.json` to use `"skills": "./skills/"` for auto-discovery
- [ ] Run `tessl project repair` to verify project link
- [ ] Run `tessl eval run . --agent "claude:claude-sonnet-4-6"` for baseline
- [ ] Check scores: fix any skill with <80% baseline
- [ ] For persona skills with no local evals, consider generating scenarios with `tessl scenario generate`

To apply: run the eval, check which skills score <80% baseline, fix their descriptions using the rules above, and re-run.

---

## Kudos

| Repo | Contribution | Contributor |
|------|-------------|-------------|
| **ruby-core-skills** | Initial v1.0.0 baseline + first-sentence strategy (54% → 87%) | @igmarin |
| **agnostic-planning-skills** | Persona hard-gate strategy + Phase 11 eval results (81% → 93%) | @igmarin |
| **hanakai-yaku** | v2.0.0 migration validation + task.md cache documentation (91% baseline) | @igmarin |
| `docs/persona-guide.md` | Shared persona reference created during hanakai-yaku migration | @igmarin |
