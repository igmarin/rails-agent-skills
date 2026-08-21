# Hotwire Progressive Enhancement Workflow

5-step workflow for adding Hotwire to any feature.

## Step 1: HTML-First

Build as plain HTML with standard form submissions.

**Verify:** Disable JavaScript and confirm the feature works completely.

## Step 2: Add Turbo Frames

Wrap targeted regions with `turbo_frame_tag`.

**Verify:** Frame scopes navigation correctly; falls back to full-page reload when JS is off.

## Step 3: Add Turbo Streams

Add `respond_to` blocks and `.turbo_stream.erb` templates.

**Verify:** Real-time DOM updates work; graceful degradation without JS.

## Step 4: Add Stimulus

Layer JavaScript behavior where declarative Turbo is insufficient.

**Verify:** Controllers connect/disconnect correctly.

## Step 5: Validation Checkpoint

After each step, disable JavaScript and confirm graceful degradation.

## Testing Checklist

- [ ] Feature works with JavaScript disabled
- [ ] Feature works with JavaScript enabled
- [ ] Turbo Frame navigation is scoped correctly
- [ ] Stream updates render correctly
- [ ] Stimulus controllers initialize properly
