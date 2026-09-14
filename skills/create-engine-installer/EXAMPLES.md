# Rails Engine Installer Examples

## Idempotent install generator

```ruby
# lib/generators/my_engine/install/install_generator.rb
module MyEngine
  class InstallGenerator < Rails::Generators::Base
    def create_initializer
      return if File.exist?(File.join(destination_root, 'config/initializers/my_engine.rb'))

      create_file 'config/initializers/my_engine.rb', <<~RUBY
        MyEngine.configure do |config|
          config.user_class = "User"
        end
      RUBY
    end

    def mount_route
      route "mount MyEngine::Engine, at: '/admin'"
    end
  end
end
```

## Generator spec — single run and idempotent rerun

```ruby
RSpec.describe MyEngine::InstallGenerator, type: :generator do
  destination File.expand_path('../../tmp', __dir__)
  before { prepare_destination }

  it 'creates the initializer' do
    run_generator
    expect(file('config/initializers/my_engine.rb')).to exist
  end

  it 'does not duplicate the initializer on rerun' do
    2.times { run_generator }
    content = File.read(file('config/initializers/my_engine.rb'))
    expect(content.scan('MyEngine.configure').size).to eq(1)
  end

  it 'does not duplicate the route mount on rerun' do
    2.times { run_generator }
    expect(File.read(file('config/routes.rb')).scan('mount MyEngine::Engine').size).to eq(1)
  end
end
```
