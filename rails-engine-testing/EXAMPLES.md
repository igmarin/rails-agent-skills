# Rails Engine Testing Examples

Executable RSpec examples for common engine testing scenarios.

## Request Spec (engine mounted in dummy app)

```ruby
# spec/requests/my_engine/root_spec.rb
require 'rails_helper'

RSpec.describe 'MyEngine mount', type: :request do
  it 'mounts the engine and returns success for the engine root' do
    get my_engine.root_path
    expect(response).to have_http_status(:ok)
  end
end
```

## Configuration Spec (engine respects host config)

```ruby
# spec/my_engine/configuration_spec.rb
RSpec.describe MyEngine::Configuration do
  around do |example|
    original = MyEngine.config.widget_count
    MyEngine.config.widget_count = 3
    example.run
    MyEngine.config.widget_count = original
  end

  it 'uses configured value' do
    expect(MyEngine.config.widget_count).to eq(3)
  end
end
```

## Generator Spec (install command, idempotent)

```ruby
# spec/generators/my_engine/install_generator_spec.rb
require 'rails_helper'
require 'generators/my_engine/install/install_generator'

RSpec.describe MyEngine::Generators::InstallGenerator, type: :generator do
  destination File.expand_path('../tmp', __dir__)

  before { prepare_destination }

  it 'copies the initializer' do
    run_generator
    expect(file('config/initializers/my_engine.rb')).to exist
  end

  it 'is idempotent' do
    2.times { run_generator }
    expect(file('config/initializers/my_engine.rb')).to exist
  end
end
```

## Reload-Safety Spec (decorator survives reload)

```ruby
# spec/my_engine/reload_safety_spec.rb
RSpec.describe 'MyEngine reload safety' do
  it 'applies decorator after reload without duplication' do
    ActiveSupport::Reloader.to_prepare {}
    expect(User.ancestors).to include(MyEngine::UserDecorator)
    expect(User.ancestors.count(MyEngine::UserDecorator)).to eq(1)
  end
end
```
