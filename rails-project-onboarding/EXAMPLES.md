# Project Onboarding Examples

Complete templates and examples for setting up development environments.

## Docker Compose Template

```yaml
# docker-compose.yml
version: '3.8'

services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: postgres
      POSTGRES_USER: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U postgres"]
      interval: 5s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  web:
    build:
      context: .
      dockerfile: Dockerfile
    command: bin/rails server -b 0.0.0.0 -p 3000
    environment:
      DATABASE_URL: postgres://postgres:postgres@db:5432/myapp_development
      REDIS_URL: redis://redis:6379/0
      RAILS_ENV: development
    ports:
      - "3000:3000"
    volumes:
      - .:/app
      - bundle_cache:/usr/local/bundle
    depends_on:
      db:
        condition: service_healthy
      redis:
        condition: service_started

volumes:
  postgres_data:
  bundle_cache:
```

## Dockerfile Template

```dockerfile
# Dockerfile
FROM ruby:3.2-slim

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  git \
  curl \
  && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy Gemfile first (for layer caching)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application
COPY . .

# Precompile assets (optional)
# RUN bundle exec rails assets:precompile

EXPOSE 3000

CMD ["bin/rails", "server", "-b", "0.0.0.0"]
```

## Environment Variables Template

```bash
# .env.example — copy to .env and fill values

# Database
DATABASE_URL=postgres://postgres:postgres@localhost:5432/myapp_development

# Rails
RAILS_ENV=development
SECRET_KEY_BASE=change_me_in_production

# Cache/Queue
REDIS_URL=redis://localhost:6379/0

# Email (optional)
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USER=your_email@example.com
SMTP_PASSWORD=your_password

# External APIs (if applicable)
STRIPE_SECRET_KEY=sk_test_...
STRIPE_PUBLISHABLE_KEY=pk_test_...

# Feature flags (optional)
ENABLE_BETA_FEATURES=false
```

## GitHub Actions CI Template

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v4

      - name: Setup Ruby
        uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
          bundler-cache: true

      - name: Setup Database
        env:
          RAILS_ENV: test
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        run: |
          bin/rails db:create db:migrate

      - name: Run Tests
        env:
          DATABASE_URL: postgres://postgres:postgres@localhost:5432/test
        run: bundle exec rspec

      - name: Run Linters
        run: |
          bundle exec rubocop
          bundle exec erb-lint app/views
```

## Makefile Template

```makefile
# Makefile — common development tasks

.PHONY: setup test lint console

setup:
	bundle install
	rails db:create db:migrate db:seed
	yarn install

test:
	bundle exec rspec

lint:
	bundle exec rubocop
	bundle exec erb-lint app/views

console:
	rails console

dev:
	rails server

docker-up:
	docker-compose up -d

docker-down:
	docker-compose down

docker-build:
	docker-compose build
```

## RuboCop Configuration Template

```yaml
# .rubocop.yml
AllCops:
  TargetRubyVersion: 3.2
  Exclude:
    - 'db/schema.rb'
    - 'bin/*'
    - 'node_modules/**/*'
    - 'vendor/**/*'

Style/Documentation:
  Enabled: false

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
    - 'config/routes.rb'

Rails:
  Enabled: true
```

## Common Troubleshooting

### Database Connection Issues

```bash
# Reset everything
rails db:drop db:create db:migrate db:seed

# Docker: ensure DB is ready
docker-compose up -d db
sleep 5  # Wait for postgres to start
rails db:create
```

### Bundle Install Failures

```bash
# Clear cache and reinstall
rm -rf vendor/bundlebundle install --path vendor/bundle

# Update bundler
gem install bundler
bundle update --bundler
```

### Asset Pipeline Issues

```bash
# Clear and rebuild
rails assets:clobber
rails assets:precompile

# For webpacker/jsbundling
rm -rf node_modules
yarn install
yarn build
```
