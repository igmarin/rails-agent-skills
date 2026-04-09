# Animal Transfer Service

## Problem/Feature Description

A network of animal shelters shares animals between locations. When a transfer is approved, the system must: (1) decrement the animal count at the source shelter, (2) increment the count at the target shelter, and (3) record a transfer log entry — all as a single atomic operation. If any step fails, the others should be rolled back. Additionally, the team needs to look up recent transfers for a given animal by tag number, and that query must be safe against injection since tag numbers are user-supplied strings from an external partner API.

Your task is to write a Ruby service for processing an animal transfer between two shelters. The service should accept source shelter ID, target shelter ID, and the animal's tag number. It should perform the multi-step update atomically, and also expose a method for querying transfer history by tag number using a raw SQL approach for performance reasons.

## Output Specification

Produce the following files:

- `app/services/<module>/<service>.rb` — the transfer service
- Any supporting documentation or companion files you consider appropriate for the module
- `spec/services/<mirrored_path>_spec.rb` — specs covering: successful transfer, source shelter not found, database failure mid-transfer (transaction rollback scenario)

Use stub comments where real ActiveRecord calls would occur (e.g. `# TODO: Shelter.find_by!(id: ...)`) so the service structure is clear without a running database.
