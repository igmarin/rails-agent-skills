# RSpec Service Testing Examples

Service object testing patterns for test-service skill.

Before implementation, report the proof:

```markdown
- First command: `bundle exec rspec spec/services/users/sync_service_spec.rb`
- Expected RED: `NameError: uninitialized constant Users::SyncService`
- GREEN rerun: `bundle exec rspec spec/services/users/sync_service_spec.rb`
```

1) Unit test for service object

```ruby
# frozen_string_literal: true
RSpec.describe Users::SyncService, type: :unit do
  describe '.call' do
    subject(:result) { described_class.call(user: user) }

    let(:user) { build(:user) }

    it 'returns success' do
      expect(result[:success]).to be true
    end

    it 'returns synced count' do
      expect(result[:response]).to include(:synced_count)
    end
  end
end
```

2) Error handling spec

RSpec.describe Users::SyncService, type: :unit do
  it 'returns error shape when external API fails' do
    allow(ExternalApi).to receive(:push).and_raise(Net::OpenTimeout)
    result = Users::SyncService.call(user: create(:user))
    expect(result[:success]).to be false
    expect(result[:response][:error]).to match(/timeout/i)
  end
end

3) Integration-style spec using perform_enqueued_jobs for background jobs

RSpec.describe 'Sync integration', type: :integration do
  it 'enqueues and performs SyncUserJob' do
    user = create(:user)
    expect { SyncUserJob.perform_later(user.id) }.to have_enqueued_job(SyncUserJob)
    perform_enqueued_jobs
    # assert side effects
  end
end
