---
name: rails-frontend-hotwire
description: >
  Creates Stimulus controllers, configures Turbo Frame lazy loading, sets up
  Turbo Stream broadcasts, and converts traditional Rails views to Hotwire
  patterns for interactive, real-time UIs. Use when the user asks about adding
  real-time updates, replacing full page reloads with Turbo, building
  interactive Rails UIs without heavy JavaScript frameworks, or wiring up
  Stimulus behavior to existing HTML. Trigger words: Hotwire, Turbo, Stimulus,
  Turbo Frames, Turbo Streams, progressive enhancement, SPA without JS.
---

# Rails Frontend Hotwire

Build modern Rails frontends with Hotwire using progressive enhancement.

**Files:** [SKILL.md](./SKILL.md) · [EXAMPLES.md](./EXAMPLES.md) · [references/workflow.md](./references/workflow.md)

## HARD-GATE

```text
ALWAYS start with HTML-only, enhance with Hotwire progressively
NEVER use Turbo Frames for full page navigation
ALWAYS test without JavaScript first
```

## Progressive Enhancement Workflow

1. **Build plain HTML** — implement the feature with standard Rails forms and links, no Hotwire.
2. **Identify update regions** — decide which parts of the page need partial updates and wrap them in `turbo_frame_tag`. Validate: load the page and confirm the `<turbo-frame>` element appears in the DOM with the correct `id`.
3. **Add Turbo Frames / Streams** — scope frame navigation or broadcast server-side changes via ActionCable. Validate: open browser DevTools Network tab and confirm frame requests return `text/vnd.turbo-stream.html` or a full frame response; for ActionCable, verify the subscription appears in the Action Cable log before proceeding.
4. **Layer Stimulus** — attach controllers only where JavaScript behaviour is needed beyond what Turbo handles. Validate: confirm `application.getControllerForElementAndIdentifier(el, 'name')` returns the controller instance in the browser console.
5. **Verify degraded mode** — disable JavaScript in browser DevTools (or run `rails test:system` with a headless driver set to `no_js`) and confirm forms submit, links navigate, and data persists correctly without JS.

See [references/workflow.md](references/workflow.md) for the full annotated workflow.

## Quick Examples

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

## Examples

See [EXAMPLES.md](EXAMPLES.md) for complete examples including:
- Turbo Frame lazy loading
- Turbo Stream broadcasting with ActionCable
- Stimulus controllers with values and classes API
- Progressive enhancement patterns

## Advanced Patterns

- **ActionCable broadcasting** — Server-push streams with `broadcasts_to`. See [EXAMPLES.md](EXAMPLES.md#actioncable-broadcasting).
- **Turbo Stream morphing** — DOM diffing (Turbo 8+). See [EXAMPLES.md](EXAMPLES.md#turbo-stream-morphing).
- **Nested frames** — Scoped frame navigation. See [EXAMPLES.md](EXAMPLES.md#nested-frames).
- **Stimulus values & classes API** — Configurable controllers. See [EXAMPLES.md](EXAMPLES.md#stimulus-values--classes-api).
