# Authorization Examples

Complete code examples for Pundit and CanCanCan implementations.

## Pundit Examples

### Policy Class

```ruby
# app/policies/post_policy.rb
class PostPolicy < ApplicationPolicy
  def update?
    user.admin? || record.user_id == user.id
  end

  def destroy?
    user.admin?
  end

  def create?
    user.present?
  end
end
```

### Controller Integration

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  before_action :set_post, only: [:update, :destroy]

  def update
    authorize @post
    if @post.update(post_params)
      redirect_to @post, notice: 'Updated successfully'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @post
    @post.destroy
    redirect_to posts_path, notice: 'Deleted successfully'
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end
end
```

## CanCanCan Examples

### Ability Class

```ruby
# app/models/ability.rb
class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user

    if user.admin?
      can :manage, :all
    else
      can :read, :all
      can :update, Post, user_id: user.id
      can :destroy, Post, user_id: user.id
      can :create, Post
    end
  end
end
```

### Controller Integration

```ruby
# app/controllers/posts_controller.rb
class PostsController < ApplicationController
  load_and_authorize_resource

  def update
    if @post.update(post_params)
      redirect_to @post, notice: 'Updated successfully'
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
```

## Testing Examples

### Pundit Policy Spec

```ruby
# spec/policies/post_policy_spec.rb
require 'rails_helper'

RSpec.describe PostPolicy do
  subject { described_class.new(user, post) }

  let(:post) { create(:post, user: owner) }
  let(:owner) { create(:user) }

  context 'as the post owner' do
    let(:user) { owner }

    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:create) }
  end

  context 'as a different user' do
    let(:user) { create(:user) }

    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.to permit_action(:create) }
  end

  context 'as an admin' do
    let(:user) { create(:user, :admin) }

    it { is_expected.to permit_action(:update) }
    it { is_expected.to permit_action(:destroy) }
    it { is_expected.to permit_action(:create) }
  end

  context 'as a guest' do
    let(:user) { nil }

    it { is_expected.not_to permit_action(:update) }
    it { is_expected.not_to permit_action(:destroy) }
    it { is_expected.not_to permit_action(:create) }
  end
end
```

### Request Spec

```ruby
# spec/requests/posts_spec.rb
require 'rails_helper'

RSpec.describe 'PATCH /posts/:id', type: :request do
  let(:post) { create(:post, user: owner) }
  let(:owner) { create(:user) }

  it 'allows the owner to update' do
    sign_in owner
    patch post_path(post), params: { post: { title: 'New Title' } }
    expect(response).to have_http_status(:ok)
    expect(post.reload.title).to eq('New Title')
  end

  it 'denies a guest' do
    patch post_path(post), params: { post: { title: 'New Title' } }
    expect(response).to have_http_status(:unauthorized)
  end

  it 'denies a different user' do
    sign_in create(:user)
    patch post_path(post), params: { post: { title: 'New Title' } }
    expect(response).to have_http_status(:forbidden)
  end

  it 'allows an admin to update any post' do
    sign_in create(:user, :admin)
    patch post_path(post), params: { post: { title: 'Admin Updated' } }
    expect(response).to have_http_status(:ok)
  end
end
```

### Shared Examples

```ruby
# spec/support/shared_examples/authorization.rb
RSpec.shared_examples 'requires authentication' do |action|
  it "requires authentication for #{action}" do
    public_send(action)
    expect(response).to redirect_to(new_user_session_path)
  end
end

RSpec.shared_examples 'requires authorization' do |action, resource_owner_method|
  it "requires authorization for #{action}" do
    other_user = create(:user)
    resource = create(described_class.controller_name.singularize, user: other_user)
    sign_in create(:user)
    public_send(action, params: { id: resource.id })
    expect(response).to have_http_status(:forbidden)
  end
end
```

## Usage in Controllers

```ruby
# spec/controllers/posts_controller_spec.rb
require 'rails_helper'

RSpec.describe PostsController do
  it_behaves_like 'requires authentication', :get, :index
  it_behaves_like 'requires authorization', :patch, :update
end
```
