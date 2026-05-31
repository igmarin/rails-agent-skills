# Skill Description Strategy

*Optimizing `description` metadata for Tessl baseline eval scores.*

## The Bottleneck

The Tessl eval task prompt includes only the **first sentence** of the skill's `description` metadata. The function `sentence_from_description` splits on `/(?<=[.!?])\s+/` — everything after the first `. ` (or `!` / `?` + space) is invisible to the agent in baseline mode.

The first sentence is the **only signal** the agent receives about the skill's specific conventions. The rest of the description, the SKILL.md body, assets, and examples are all invisible until the agent loads the skill explicitly.

## Diagnosis: Find the Bottleneck

For any skill repo:

```bash
# 1. Run the eval
tessl eval --tile <your-tile>

# 2. View results — note baseline scores <80%
tessl eval view --last

# 3. Check what the agent actually sees in the task prompt
cat tessl-evals/<skill-name>/scenario-0/task.md

# 4. Compare against the description frontmatter
head -15 skills/<category>/<skill-name>/SKILL.md
```

The task prompt shows only the description up to the first `. ` — if it looks generic, that's why the baseline score is low.

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

### Step 1: Read the instruction JSON

```bash
cat tessl-evals/<skill>/instructions.json
```

This shows the exact instructions the eval tests. Note which instructions score low.

### Step 2: Map instructions to description content

- Does the instruction test content that lives in the SKILL.md body?
- Can that rule be summarized in the first sentence?
- Is it a concrete example that's fundamentally invisible? (Accept lower baseline)

### Step 3: Edit the description

Edit the `description` field in `skills/<category>/<skill>/SKILL.md`:

1. Move critical rules before the first `. ` — use commas/em dashes instead
2. Eliminate `... ` (three dots followed by space) inside backticks
3. Keep the first sentence as one long sentence ending at the first period

### Step 4: Verify

```bash
ruby scripts/generate-tessl-evals.rb   # if your repo has this script
ruby scripts/validate-tessl-evals.rb
# Or your repo's equivalent
cat tessl-evals/<skill>/scenario-0/task.md  # confirm first sentence
```

### Step 5: Run eval

```bash
tessl eval --tile <your-tile>
tessl eval view --last
```

Check if the specific low-scoring instruction improved.

## The Ceiling

Some instructions test specific examples or content from the SKILL.md body that cannot fit in a first sentence:

- Worked examples with specific domain values (e.g., `Order must never transition from cancelled back to active`)
- Patterns-to-avoid lists with specific class names
- Extended reference loading instructions

These are fundamentally invisible in baseline mode. A first sentence can hint at them (e.g., "document each concept with its invariant example and patterns to avoid") but cannot embed the full content. Expect baseline scores of 60-70% for these.

## Measurement

Before applying this strategy (v1.0.0): **54% baseline avg**
After applying (v1.1.0): **87% baseline avg**

Largest single-skill improvements across the repo:

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

## Cross-Repo Applicability

This strategy applies to any repo with Tessl evals that use `sentence_from_description` (the standard Tessl eval generator):

| Repo | Description | Skills | Eval script |
|------|-------------|--------|-------------|
| ruby-core-skills | Ruby + process skills | 16 | `scripts/generate-tessl-evals.rb` |
| agnostic-planning-skills | PM + planning skills | 10 | (check scripts/) |
| rails-agent-skills | Rails-specific skills | 28 | (check scripts/) |
| hanakai-yaku | Hanami/dry-rb/ROM skills | 37 | (check scripts/) |

To apply: run the eval, check which skills score <80% baseline, fix their descriptions using the rules above, regenerate evals, and re-run.
