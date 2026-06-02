# Invoice Spec Refactor — Test Data Hygiene

## Problem/Feature Description

The backend team has been struggling with a slow spec suite and brittle tests in the `Invoice` model spec. A senior engineer suspects the issue is in how test data is being set up: records are being created in the database unnecessarily, and factories are being loaded with many attributes that aren't relevant to the behaviors under test.

The spec is located at `inputs/spec/models/invoice_spec.rb`. Your task is to rewrite it to improve test data hygiene while preserving the same behavioral coverage. Reduce unnecessary database writes, trim factory attribute lists to only what's needed for each behavior, and ensure time-dependent assertions can't become flaky.

## Output Specification

Produce an `answer.md` file containing:
- The rewritten spec file with its path shown
- An explanation of each test-data hygiene improvement made
- Confirmation that the same behaviors are still tested
