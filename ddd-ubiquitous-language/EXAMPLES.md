# DDD Ubiquitous Language — Examples

Extended patterns for this skill. Read [SKILL.md](./SKILL.md) first.

## Example — Naming Inconsistency in a Rails App

### Input (fuzzy ticket / PRD excerpt)

> "When a customer books a vehicle, the system should create a hold so fleet managers can confirm the reservation before it expires. The booking service currently calls `HoldService` but the controller is `ReservationsController` and the model is `Booking`."

Terms spotted: *books*, *hold*, *reservation*, *booking*, *Booking* (model), *ReservationsController*, *HoldService*.

### Output (resolved glossary)

A Rails app has `Booking` (model), `ReservationsController`, and `HoldService` all referring to the same concept. The resulting glossary resolves it:

| Canonical term | Aliases | Definition | Invariant | Context |
|----------------|---------|------------|-----------|---------|
| Reservation | Booking, Hold | A customer claim on an inventory slot for a future date | Must expire or be confirmed within 24h | Fleet Booking |

**Open questions:** Does "Hold" ever refer to a separate short-lived state before a Reservation is created, or is it always the same concept? If separate, it needs its own entry.

Once the glossary is agreed, rename code toward the canonical term incrementally — do not rename all 50 call sites in one PR.

## Common Mistakes

| Mistake | Reality |
|---------|---------|
| Keeping every synonym alive forever | Pick one preferred business term or the codebase stays muddy |
| Using technical class names as domain truth | Domain language comes from the business, not from current code accidents |
| Jumping to aggregates before agreeing on words | Overloaded terms produce bad boundaries and bad models |
| One term meaning different things in different screens | Flag it early — it usually signals multiple bounded contexts |
