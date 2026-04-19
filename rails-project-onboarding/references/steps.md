# Detailed Setup Steps

Complete walkthrough for each step of project onboarding.

## Step 1: Clone and Inspect

### Clone Repository

```bash
git clone <repository-url>
cd <project-directory>
```

### Verify Structure

```bash
ls -la
# Should see: Gemfile, bin/, config/, app/, spec/ or test/
```

### Check Ruby Version

```bash
cat .ruby-version  # or: cat Gemfile | grep ruby
ruby -v  # Verify installed version matches
```

## Step 2: Environment Variables

### Copy Example File

```bash
cp .env.example .env
# Edit .env with your values
```

### Generate Secret Key

```bash
rails secret
# Copy output to SECRET_KEY_BASE in .env
```

### Verify Environment

```bash
rails runner 'puts ENV["RAILS_ENV"]'
# Should output: development
```

## Step 3: Docker Setup

### Start Services

```bash
docker-compose up -d
```

### Verify Containers

```bash
docker-compose ps
# Both web and db should show "Up"
```

### View Logs

```bash
docker-compose logs -f web
docker-compose logs -f db
```

## Step 4: Dependencies

### Ruby Gems

```bash
bundle install
```

### JavaScript Packages

```bash
# For yarn
yarn install

# For npm
npm install

# For importmaps (no action needed)
```

### Verify

```bash
bundle exec ruby -e 'puts :ok'
# Should print: ok
```

## Step 5: Database

### Create and Migrate

```bash
rails db:create db:migrate
```

### Seed Data

```bash
rails db:seed
```

### Verify

```bash
rails db:migrate:status
# All migrations should show "up"
```

## Step 6: Linters

### RuboCop

```bash
bundle exec rubocop
# Fix any offenses before committing
```

### Auto-fix

```bash
bundle exec rubocop -A
```

## Step 7: IDE Setup

### VS Code Extensions

- Shopify.ruby-lsp
- karunamurti.haml
- syler.sass-indented
- formulahendry.auto-close-tag

### Ruby LSP Configuration

```json
// .vscode/settings.json
{
  "rubyLsp.formatter": "rubocop",
  "rubyLsp.linters": ["rubocop"],
  "editor.formatOnSave": true
}
```

## Final Verification

### Run Tests

```bash
bundle exec rspec
# All tests should pass
```

### Start Server

```bash
rails server
# Visit http://localhost:3000
```

### Check Health

```bash
curl http://localhost:3000/up
# Should return 200 OK
```
