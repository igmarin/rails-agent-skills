# Rails-First Slice Heuristics

Use the smallest slice that proves behavior at the right boundary:

| Change type | Default first slice |
|-------------|---------------------|
| New endpoint or controller behavior | Request spec -> controller/service wiring -> persistence/docs |
| New service or domain rule | Service or model spec -> implementation -> callers/docs |
| Background work | Job spec -> service/domain spec if logic is substantial |
| External integration | Client/fetcher layer spec -> builder/domain mapping -> callers |
| Rails engine work | Engine request/routing/generator spec -> engine code -> install/docs |
| Bug fix | Highest-value reproducing spec at the boundary where users feel the bug |

When in doubt, prefer the highest-value failing spec that proves the user-visible behavior before descending into lower-level units.
