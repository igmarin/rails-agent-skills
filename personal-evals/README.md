# Personal Evaluations Framework

This directory contains open example evaluation scenarios for measuring the effectiveness of the skills and workflows in this repository.

These scenarios are the source of truth for the custom evaluator. The XML context builder includes only the target `SKILL.md`; it does not follow links or load sibling files or assets. Add any scenario-specific input to `task.md` or provide it separately to the evaluator.

Scenarios that target skills in `ruby-core-skills` (`create-service-object`, `model-domain`, `triage-bug`) live in that repo's `personal-evals/`.

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

Every scenario must include metadata that follows `personal-evals/schema.json`. Use it to declare the target skill, persona, or workflow, the XML context mode, whether companion resources must be provided separately, and Tessl export support.

```json
{
  "id": "workflow-rails-tdd-loop",
  "target_type": "workflow",
  "target_name": "rails-feature",
  "context_mode": "skill_bundle_xml",
  "requires_companion_resources": false,
  "tessl_export": {
    "supported": false,
    "reason": "This custom evaluation uses repository-specific XML context and metadata; no Tessl-native export is configured."
  }
}
```

## XML Context Bundle

The builder emits the target `SKILL.md` as the primary XML document. It does not automatically include companion resources:

- Linked docs, examples, and files under `assets/` are not loaded.
- `requires_companion_resources` is `true` only when the evaluator supplies those materials separately; the context builder does not.

Generate a bundle for inspection:

```bash
ruby scripts/eval_context_builder.rb skills/create-engine
ruby scripts/eval_context_builder.rb skills/rails-feature --target-type workflow
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
