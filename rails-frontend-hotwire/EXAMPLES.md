# Hotwire Examples

Complete code examples for Turbo and Stimulus implementations.

## Turbo Frames

### Basic Frame

```erb
<!-- app/views/posts/index.html.erb -->
<h1>Posts</h1>

<%= turbo_frame_tag "posts_list" do %>
  <%= render @posts %>
<% end %>
```

### Frame with New Post Form

```erb
<!-- app/views/posts/index.html.erb -->
<%= turbo_frame_tag "new_post" do %>
  <%= link_to "New Post", new_post_path %>
<% end %>

<%= turbo_frame_tag "posts_list" do %>
  <%= render @posts %>
<% end %>
```

```erb
<!-- app/views/posts/new.html.erb -->
<%= turbo_frame_tag "new_post" do %>
  <%= render "form", post: @post %>
<% end %>
```

### Lazy-Loaded Frame

```erb
<!-- Load content when frame scrolls into view -->
<%= turbo_frame_tag "comments", src: post_comments_path(@post), loading: :lazy do %>
  <p>Loading comments...</p>
<% end %>
```

## Turbo Streams

### Stream Template for Create

```erb
<!-- app/views/posts/create.turbo_stream.erb -->
<%= turbo_stream.append "posts_list", partial: "post", locals: { post: @post } %>
<%= turbo_stream.update "new_post", partial: "posts/new_link" %>
<%= turbo_stream.update "post_count", Post.count %>
```

### Stream Template for Update

```erb
<!-- app/views/posts/update.turbo_stream.erb -->
<%= turbo_stream.replace @post, partial: "post", locals: { post: @post } %>
```

### Stream Template for Destroy

```erb
<!-- app/views/posts/destroy.turbo_stream.erb -->
<%= turbo_stream.remove @post %>
<%= turbo_stream.update "post_count", Post.count %>
```

### Broadcasting with ActionCable

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  after_create_commit -> { broadcast_append_to "posts" }
  after_update_commit -> { broadcast_replace_to "posts" }
  after_destroy_commit -> { broadcast_remove_to "posts" }
end
```

```erb
<!-- app/views/posts/index.html.erb -->
<%= turbo_stream_from "posts" %>
<%= turbo_frame_tag "posts_list" do %>
  <%= render @posts %>
<% end %>
```

## Stimulus Controllers

### Basic Controller

```javascript
// app/javascript/controllers/clipboard_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "button"]

  copy() {
    navigator.clipboard.writeText(this.sourceTarget.value)
    this.buttonTarget.textContent = "Copied!"
    setTimeout(() => {
      this.buttonTarget.textContent = "Copy"
    }, 2000)
  }
}
```

```erb
<!-- app/views/posts/show.html.erb -->
<div data-controller="clipboard">
  <input data-clipboard-target="source" type="text" value="<%= post_url(@post) %>" readonly>
  <button data-action="clipboard#copy" data-clipboard-target="button">Copy</button>
</div>
```

### Controller with Values

```javascript
// app/javascript/controllers/slideshow_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide"]
  static values = { index: Number }

  next() {
    this.indexValue++
  }

  previous() {
    this.indexValue--
  }

  indexValueChanged() {
    this.showCurrentSlide()
  }

  showCurrentSlide() {
    this.slideTargets.forEach((slide, index) => {
      slide.hidden = index !== this.indexValue
    })
  }
}
```

```erb
<div data-controller="slideshow" data-slideshow-index-value="0">
  <button data-action="slideshow#previous">←</button>
  <button data-action="slideshow#next">→</button>

  <div data-slideshow-target="slide">🐵</div>
  <div data-slideshow-target="slide" hidden>🙈</div>
  <div data-slideshow-target="slide" hidden>🙉</div>
  <div data-slideshow-target="slide" hidden>🙊</div>
</div>
```

### Form Validation Controller

```javascript
// app/javascript/controllers/form_validation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "error"]

  validate() {
    if (this.inputTarget.value.length < 5) {
      this.errorTarget.textContent = "Must be at least 5 characters"
    } else {
      this.errorTarget.textContent = ""
    }
  }
}
```

```erb
<%= form_with model: @post, data: { controller: "form-validation" } do |f| %>
  <%= f.text_field :title,
    data: {
      form_validation_target: "input",
      action: "input->form-validation#validate"
    } %>
  <span data-form-validation-target="error" class="error"></span>
<% end %>
```

## Progressive Enhancement Examples

### HTML-First Form

```erb
<!-- Step 1: Plain HTML (works without JS) -->
<%= form_with model: @post do |f| %>
  <%= f.text_field :title %>
  <%= f.text_area :body %>
  <%= f.submit "Create Post" %>
<% end %>
```

### With Turbo Frame

```erb
<!-- Step 2: Wrap in frame for partial updates -->
<%= turbo_frame_tag "post_form" do %>
  <%= form_with model: @post do |f| %>
    <%= f.text_field :title %>
    <%= f.text_area :body %>
    <%= f.submit "Create Post" %>
  <% end %>
<% end %>
```

### With Turbo Streams

```ruby
# Step 3: Add controller response
class PostsController < ApplicationController
  def create
    @post = Post.new(post_params)

    if @post.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @post }
      end
    else
      render :new, status: :unprocessable_entity
    end
  end
end
```

## Advanced Patterns

### ActionCable Broadcasting

Real-time updates via WebSocket:

```ruby
# app/models/post.rb
class Post < ApplicationRecord
  broadcasts_to ->(post) { [post.board, "posts"] }, inserts_by: :prepend
end
```

### Turbo Stream Morphing

Surgical DOM updates (Turbo 8+):

```erb
<%= turbo_stream.morph @post, partial: "posts/post", locals: { post: @post } %>
```

### Nested Frames

Scoped navigation with nested turbo frames:

```erb
<%= turbo_frame_tag "board" do %>
  <%= turbo_frame_tag "post_#{@post.id}" do %>
    <%= link_to "Edit", edit_post_path(@post) %>
  <% end %>
<% end %>
```

### Stimulus Values & Classes API

Configurable, CSS-decoupled controllers:

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String, delay: { type: Number, default: 300 } }
  static classes = ["active"]

  connect() {
    this.element.classList.add(this.activeClass)
    console.log("Fetching from", this.urlValue, "after", this.delayValue, "ms")
  }
}
```

```html
<div data-controller="loader"
     data-loader-url-value="/posts"
     data-loader-delay-value="500"
     data-loader-active-class="is-loading">
</div>
