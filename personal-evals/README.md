# Personal Evaluations Framework

This directory contains open example evaluation scenarios for measuring the effectiveness of the skills and workflows in this repository.

These scenarios are the source of truth for the custom evaluator. They are not Tessl-native evals today because the custom evaluator loads a full XML context bundle: the target `SKILL.md` plus companion resources discovered from the skill or workflow directory.

The root `evals/` directory is reserved for generated Tessl staging output. Do not commit files under root `evals/`; generating that directory changes what Tessl runs for this repository.

## The Goal: Measuring "Lift"

Every evaluation is designed to be run in two modes:
1.  **Baseline:** Raw LLM with no repository context.
2.  **With Context:** LLM provided with the XML context bundle for the relevant skill or workflow.

The goal is to prove that our skills provide a significant improvement over the base model's default behavior.

## Scenario Structure

Each evaluation lives in its own directory (e.g., `skill-create-service-object/`) and must contain:

### 1. `task.md` (The Prompt)
A complex, representative scenario that forces the agent to use the skill's specific instructions.
- **Complexity:** Avoid simple tasks. Give the agent "messy" code to refactor or complex requirements to implement.
- **Context:** Provide enough background info to make the task realistic.

### 2. `criteria.json` (The Rubric)
A weighted checklist that evaluates adherence to our **strict conventions** and **hard-gates**.
- **Focus:** Don't just evaluate if the code works. Evaluate *how* it was built.
- **Convention over generic:** Reward specific naming, structure, and documentation requirements defined in the skill.
- **Weighted Scores:** Assign higher points to non-negotiable hard-gates.

### 3. `metadata.json` (The Target Contract)

Every scenario must include metadata that follows `personal-evals/schema.json`. Use it to declare the target skill or agent, the XML context mode, and whether the scenario can be exported to Tessl later.

```json
{
  "id": "workflow-rails-tdd-loop",
  "target_type": "agent",
  "target_name": "tdd",
  "context_mode": "skill_bundle_xml",
  "requires_companion_resources": true,
  "tessl_export": {
    "supported": false,
    "reason": "Requires XML bundle with companion resources; Tessl currently consumes SKILL.md only."
  }
}
```

## XML Context Bundle

The evaluator builds context by filesystem convention:

- `SKILL.md` is always the primary document.
- Direct companion text files such as `EXAMPLES.md`, `TESTING.md`, `TASK_TEMPLATES.md`, `PATTERNS.md`, and `HEURISTICS.md` are included.
- Text files under `assets/` are included recursively.
- Binary files are skipped.
- Resources are sorted by path so prompts are deterministic.

Generate a bundle for inspection:

```bash
ruby scripts/eval_context_builder.rb skills/patterns/create-service-object
ruby scripts/eval_context_builder.rb skills/personas/tdd
```

## Best Practices

- **Read-Only:** These scenarios are for evaluation only. Do not "fix" the provided messy code in the `task.md` inputs.
- **Representative:** Scenarios should mimic the actual work a Senior Rails Engineer would do.
- **Isolation:** Each folder should test exactly one skill or workflow.
- **Tessl isolation:** Keep `personal-evals/` independent from the `evals/` Tessl scenario source.

## Running Evaluations

Use the custom evaluator to execute these scenarios. Run repository checks before committing eval changes:

```bash
bash scripts/validate-evals.sh
```
