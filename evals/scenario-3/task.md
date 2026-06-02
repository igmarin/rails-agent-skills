# RSpec Convention Audit and Cleanup

## Problem/Feature Description

A developer on the team wrote a spec for the `Reports::GenerateReport` service and submitted it for code review. The reviewer flagged several convention violations but did not specify which ones, leaving the original author to self-correct. The spec is located at `inputs/spec/services/reports/generate_report_spec.rb`.

Your task is to review this spec file and produce a corrected version that follows all current RSpec conventions used by this project. In addition to fixing any violations found, you should document each issue identified and explain what the correct approach is.

## Output Specification

Produce an `answer.md` file that includes:
- A list of each convention violation found in the original spec, with a brief explanation
- The corrected spec file (full content, not just diffs)
- Confirmation that the corrected spec file still tests the same behaviors as the original
