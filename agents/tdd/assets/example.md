# End-to-End Example

Complete walkthrough of the TDD loop for a `User#full_name` method.

## Step 1: Write Spec (`spec/models/user_spec.rb`)

```ruby
RSpec.describe User do
  describe '#full_name' do
    let(:user) { build(:user, first_name: 'John', last_name: 'Doe') }
    it 'concatenates first and last name' do
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

## Step 2: Run RED

```bash
bundle exec rspec spec/models/user_spec.rb
```

Expected failure: `undefined method 'full_name'` (feature missing, not a typo/config error)

## Step 3: Propose Implementation

Propose approach: "User#full_name: concatenate first_name + last_name with space"

Wait for user approval.

## Step 4: Implement (`app/models/user.rb`)

```ruby
def full_name
  "#{first_name} #{last_name}"
end
```

## Step 5: Run GREEN

```bash
bundle exec rspec spec/models/user_spec.rb
```

Expected: spec passes

## Step 6: Proceed to Phase 4

Run linters and full test suite, generate YARD docs, self-review PR.
