---
name: implement-hotwire
type: atomic
license: MIT
description: >
  Use when creating Hotwire UIs with progressive enhancement in Rails — generates Stimulus controllers, Turbo Frame markup, Turbo Stream responses, and ActionCable broadcast setups, then verifies degraded mode by disabling JavaScript (or running rails test:system with Capybara rack_test driver) and confirming forms submit, links navigate, and data persists after reload. Includes a Verification section with explicit no-JavaScript checks. Stimulus, Turbo, Turbo Frames, Turbo Streams.
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
2. **Identify update regions** — wrap partial-update areas in `turbo_frame_tag`. Validate: confirm `<turbo-frame>` appears in the DOM with the correct `id`.
3. **Add Turbo Frames / Streams** — scope frame navigation or broadcast via ActionCable. Validate: confirm frame requests return `text/vnd.turbo-stream.html` in DevTools Network tab; for ActionCable, verify the subscription appears in the Action Cable log.
4. **Layer Stimulus** — attach controllers only where JavaScript behaviour is needed beyond Turbo. Validate: confirm `application.getControllerForElementAndIdentifier(el, 'name')` returns the controller instance in the browser console.
5. **Verify degraded mode** — disable JavaScript in browser DevTools (or run `rails test:system` with the Capybara `:rack_test` driver) and confirm all hold without JS: forms submit, links navigate, data persists after reload.

## Code Examples

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
Register in `app/javascript/controllers/index.js`:
```javascript
import GreetController from "./greet_controller"
application.register("greet", GreetController)
```

## Output Style

When implementing Hotwire, your output MUST include:
1. **Progressive baseline** — how the feature works with plain HTML before enhancement.
2. **Chosen primitive** — Turbo Frame, Turbo Stream, Stimulus, or combination, and why.
3. **DOM contract** — frame IDs, stream targets, Stimulus controller names, targets, values, and actions.
4. **Server contract** — controller response formats, broadcast triggers, partial names, and ActionCable channel/log checks when used.
5. **Verification** — degraded-mode checklist from Core Process step 5, plus system/browser checks for frame, stream, or Stimulus behavior.
6. **Language** — English unless explicitly requested otherwise.

## Extended Resources (Progressive Disclosure)

Load these files only when their specific content is needed:

- **[EXAMPLES.md](EXAMPLES.md)** — Use when you need full worked examples of Turbo Frames, Streams, and Stimulus patterns
- **[references/workflow.md](references/workflow.md)** — Use when you need the step-by-step Hotwire implementation workflow and decision tree

## Integration

| Skill | When to chain |
|-------|---------------|
| **write-tests** | For system specs and failing interaction coverage |
| **apply-stack-conventions** | For Rails + Hotwire + Tailwind stack alignment |
| **code-review** | After the UI behavior and degraded mode are verified |
