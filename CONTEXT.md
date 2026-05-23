# Glossary

## TDD Gate (Tests Gate Implementation)
The non-negotiable rule that implementation code cannot be written until a test exists, has been run, and has failed for the right reason. This is the foundational discipline of the library.

## Skill
An atomic unit of agent instructions stored in `SKILL.md` files. There are 38 public skills in this library, categorized by Rails development concern.

## Agent

A high-level orchestrator that chains multiple atomic skills into a complete development loop (e.g., `tdd`, `bug-fix`, `review`). There are 9 agents available in `agents/`. Discover via `list_agents`.

## Skill Router
A specialized skill (orchestrator) used to determine which atomic skills apply to a given user request.
