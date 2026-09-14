# First Slice Template

Use this template when the task is to choose the first failing spec.

````markdown
## Behavior

[User-visible behavior or invariant to prove]

## Boundary Decision

| Candidate | Keep/Reject | Reason |
| --- | --- | --- |
| Request spec | Keep/Reject | [HTTP/routing/serialization risk?] |
| Service spec | Keep/Reject | [orchestration boundary?] |
| Model spec | Keep/Reject | [domain invariant?] |
| Job spec | Keep/Reject | [async behavior?] |
| System spec | Keep/Reject | [browser-only risk?] |

## Opening Gate

- Spec path: `spec/...`
- First focused command: `bundle exec rspec spec/...`
- Expected RED reason: `[feature missing, not broken setup]`

```ruby
it 'proves one observable behavior' do
  # exactly one opening example
end
```

## Follow-up Coverage

- [ ] [Additional case after the opening gate is green]

## HARD-GATE Design Checkpoint

| Question | Answer |
| --- | --- |
| Does this test cover the right behavior? | Yes/No |
| Is the boundary correct? | Yes/No |
| Are the most important edge cases represented or listed for follow-up? | Yes/No |
| Is the failure reason correct? | Yes/No |
````
