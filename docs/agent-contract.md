# Execution contract

Load this contract when applying a skill from this pack.

1. Inspect project instructions, installed versions, and neighboring code before selecting a workflow. Project conventions and the user's accepted requirements take precedence over examples and defaults here.
2. Continue work already authorized through verification. Ask only for missing decisions that materially change scope or for actions requiring fresh authority. Inherit host permissions and model settings; skill text grants neither. A small fix does not require a PRD or delegation.
3. Load required skills by catalog identity before applying them. Report missing required dependencies as blockers with the needed pack and skill; disclose optional omissions. Routers select procedures and continue into them when execution is requested.
4. Keep real test gates: observe a failure caused by missing behavior before implementation; preserve passing characterization tests for refactors. Report command, exit status, and actual evidence. Mark unrun checks as unrun; examples and expected output are never proof.
5. For multi-stage work, persist a checkpoint in the project's existing task artifact (otherwise `docs/agent-checkpoint.md`): objective, acceptance criteria, selected pack-qualified skills, completed checks, changed artifacts, remaining work, and blockers. Resume by checking current files and rerunning only checks invalidated by changes.

## Compatibility

Existing catalog names and paths remain valid. The composition layer identifies skills as `<pack-id>:<skill-name>` and maps host exports explicitly. Legacy `persona` classifications in the catalog describe workflows, not additional permissions or an independent agent identity. Contributor instructions in root `AGENTS.md` govern maintenance of this repository; they are not installed role instructions.
