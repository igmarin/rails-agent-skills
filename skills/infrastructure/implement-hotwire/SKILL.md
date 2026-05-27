---
name: implement-hotwire
license: MIT
description: >
  Creates Hotwire UIs with progressive enhancement — ALWAYS start with plain HTML, NEVER use Turbo Frames for full page navigation, output MUST include Verification: verify degraded mode without JavaScript (disable JS in browser or run `rails test:system` with Capybara `:rack_test` driver, checklist must confirm forms submit/links navigate/data persists after reload), plus system/browser checks for frame/stream/Stimulus behavior, use Turbo Frames for replacing page sections, Turbo Streams for broadcasting, Stimulus only when beyond Turbo. Trigger words: Hotwire, Turbo, Stimulus, Turbo Frames, Turbo Streams, progressive enhancement.
metadata:
  version: 1.0.0
  user-invocable: "true"
---

# Implement Hotwire

Build modern Rails frontends with Hotwire using progressive enhancement.

## Quick Reference

| Need | Hotwire choice |
|------|----------------|
| Replace part of a page after a link/form | Turbo Frame |
| Broadcast server-side changes | Turbo Stream |
| Client-only behavior beyond Turbo | Stimulus controller |
| Full page navigation | Normal Rails navigation, not a frame |

## HARD-GATE

```text
ALWAYS start with HTML-only, enhance with Hotwire progressively
NEVER use Turbo Frames for full page navigation
ALWAYS test without JavaScript first
```

## Core Process

1. **Build plain HTML** — implement the feature with standard Rails forms and links, no Hotwire.
2. **Identify update regions** — decide which parts of the page need partial updates and wrap them in `turbo_frame_tag`. Validate: load the page and confirm the `<turbo-frame>` element appears in the DOM with the correct `id`.
3. **Add Turbo Frames / Streams** — scope frame navigation or broadcast server-side changes via ActionCable. Validate: open browser DevTools Network tab and confirm frame requests return `text/vnd.turbo-stream.html` or a full frame response; for ActionCable, verify the subscription appears in the Action Cable log before proceeding.
4. **Layer Stimulus** — attach controllers only where JavaScript behaviour is needed beyond what Turbo handles. Validate: confirm `application.getControllerForElementAndIdentifier(el, 'name')` returns the controller instance in the browser console.
5. **Verify degraded mode** — disable JavaScript in browser DevTools (or run `rails test:system` with a headless driver set to `no_js`) and confirm forms submit, links navigate, and data persists correctly without JS.

## Extended Resources

**Quick Examples**
### Turbo Frame
```erb
<%= turbo_frame_tag "post_#{@post.id}" do %>
  <h1><%= @post.title %></h1>
  <%= link_to "Edit", edit_post_path(@post) %>
<% end %>
```

### Turbo Stream
```erb
<%= turbo_stream.append "posts", partial: "post", locals: { post: @post } %>
```

### Stimulus Controller
```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name"]
  greet() { alert(`Hello ${this.nameTarget.value}!`) }
}
```
Register the controller in `app/javascript/controllers/index.js`:
```javascript
import GreetController from "./greet_controller"
application.register("greet", GreetController)
```

**Advanced Patterns**
- **ActionCable broadcasting** — Server-push streams with `broadcasts_to`. See [EXAMPLES.md](EXAMPLES.md#actioncable-broadcasting).
- **Turbo Stream morphing** — DOM diffing (Turbo 8+). See [EXAMPLES.md](EXAMPLES.md#turbo-stream-morphing).
- **Nested frames** — Scoped frame navigation. See [EXAMPLES.md](EXAMPLES.md#nested-frames).
- **Stimulus values & classes API** — Configurable controllers. See [EXAMPLES.md](EXAMPLES.md#stimulus-values-classes-api).

- [SKILL.md](./SKILL.md)
- [EXAMPLES.md](./EXAMPLES.md)
- [references/workflow.md](./references/workflow.md)

## Output Style

When implementing Hotwire, your output MUST include:
1. **Progressive baseline** — State how the feature works with normal HTML before Hotwire enhancement.
2. **Chosen primitive** — Name Turbo Frame, Turbo Stream, Stimulus, or a combination, and why.
3. **DOM contract** — List frame IDs, stream targets, Stimulus controller names, targets, values, and actions.
4. **Server contract** — State controller response formats, broadcast triggers, partial names, and ActionCable channel/log checks when used.
5. **Verification** — Include no-JavaScript degraded-mode check plus system/browser checks for frame, stream, or Stimulus behavior. The degraded-mode checklist must explicitly include: `rails test:system` with the Capybara `:rack_test` driver, or the equivalent driver name in the test configuration, forms submit, links navigate, and data persists after reload.
6. Language — Must be in English unless explicitly requested otherwise.

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | For system specs and failing interaction coverage |
| **apply-stack-conventions** | For Rails + Hotwire + Tailwind stack alignment |
| **code-review** | After the UI behavior and degraded mode are verified |
