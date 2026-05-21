---
name: background-job
license: MIT
description: >
  Orchestrates robust background job implementation: design job → TDD implementation → configure retry/discard strategies → test failure scenarios → production monitoring. Use when adding async processing, implementing background jobs, or configuring job queues. Trigger: background job, async processing, sidekiq, solid queue, active job, job queue, worker.
metadata:
  version: 1.0.0
  user-invocable: "true"
  entry_point: "Invoke when implementing background jobs with proper retry/discard strategies and monitoring"
  phases: "Phase 1: Job Design, Phase 2: TDD Implementation, Phase 3: Retry/Discard Configuration, Phase 4: Testing & Monitoring"
  hard_gates: "Job Design Complete, Tests Pass, Retry Strategy Configured, Failure Scenarios Tested"
  dependencies: "implement-background-job, write-tests"
  keywords: rails, background-job, async, sidekiq, solid-queue, active-job, retry, monitoring
---
# Background Job Agent

Orchestrates robust background job implementation with TDD discipline, proper retry/discard strategies, comprehensive failure scenario testing, and production monitoring to ensure reliable async processing.

## When to Use

- Adding new background jobs for async processing
- Implementing email notifications, reports, or data processing
- Configuring job queues and workers
- Setting up scheduled/recurring jobs
- Migrating from synchronous to asynchronous processing
- Implementing retry logic for external API calls

## Agent Phases

### Phase 1: Job Design

**Objective:** Design background job with clear responsibilities and error handling strategy.

**Steps:**
1. **Job Purpose Definition** — Define what the job does and when it runs:
   - Trigger conditions (event-based, scheduled, manual)
   - Input parameters and data requirements
   - Expected output and side effects
   - Failure impact and criticality
2. **Idempotency Design** — Ensure job can be safely retried:
   - Design job to be idempotent (safe to run multiple times)
   - Use unique job keys to prevent duplicate execution
   - Implement status tracking to avoid duplicate work
3. **Error Classification** — Classify potential errors:
   - Transient errors (network timeouts, rate limits) → retry
   - Permanent errors (invalid data, not found) → discard
   - Configuration errors (missing credentials) → alert

**Job Design Guidelines:**
- Keep jobs focused and single-purpose
- Design for idempotency and safe retries
- Use appropriate queue based on priority
- Implement proper logging and monitoring
- Consider job duration and timeouts

**HARD GATE — Job Design Complete:**
- Job purpose clearly defined
- Input/output parameters specified
- Idempotency strategy designed
- Error classification complete
- Queue strategy determined
- Timeout and retry requirements identified

**If gate fails:** Job design is incomplete. Clarify requirements before implementation.

**Example Job Design:**
```markdown
# Background Job Design: OrderConfirmationEmail

## Purpose
Send order confirmation email when order is completed

## Trigger
Event-based: Order.status transitions to 'completed'

## Input
- order_id (Integer)
- customer_email (String)
- order_total (Float)

## Output
- Email sent via external API
- Order email_sent_at timestamp updated

## Idempotency
- Check if email already sent before sending
- Use unique job key: "order_confirmation_#{order_id}"
- Update email_sent_at only after successful send

## Error Classification
- Transient: Email API timeout (retry with exponential backoff)
- Transient: Rate limit exceeded (retry with longer delay)
- Permanent: Invalid email address (discard with error logging)
- Permanent: Order not found (discard)
- Configuration: Missing API credentials (alert team)

## Queue
default (normal priority)

## Timeout
30 seconds
```

---

### Phase 2: TDD Implementation

**Objective:** Implement background job using TDD discipline.

### TDD Enforcement for Background Jobs

**Before implementing job logic:**
1. **testing/plan-tests** — Choose test approach:
   - Unit tests for job logic
   - Integration tests for job execution
   - Fake worker for testing job enqueue
2. **testing/write-tests** — Write failing tests for job:
   - Test successful job execution
   - Test idempotency (job can run twice safely)
   - Test error handling and retry behavior
3. **Test Verification** — Confirm tests FAIL for right reason (job not implemented)
4. **Implementation Proposal** — Propose job implementation approach
5. **User Approval** — Wait for explicit confirmation
6. **Implement Job** — Write background job code
7. **Verify PASS** — Run tests to confirm they pass
8. **Regression Check** — Run full test suite

**HARD GATE — Test Verification:**
- Tests EXISTS and RUNS
- Tests FAIL for correct reason before implementation
- Tests PASSES after implementation
- Idempotency tests pass
- Error handling tests pass
- Full test suite PASSES

**If test fails for wrong reason:** Fix test (not implementation) to accurately test job behavior.

**Example Job Test:**
```ruby
# spec/jobs/order_confirmation_email_job_spec.rb
RSpec.describe OrderConfirmationEmailJob do
  let(:order) { create(:order, :completed) }

  it 'sends confirmation email' do
    expect(EmailService).to receive(:send_confirmation).with(order.id, order.customer_email, order.total)
    described_class.perform_now(order.id, order.customer_email, order.total)
  end

  it 'is idempotent' do
    expect(EmailService).to receive(:send_confirmation).once
    described_class.perform_now(order.id, order.customer_email, order.total)
    described_class.perform_now(order.id, order.customer_email, order.total)
  end

  it 'handles email service errors with retry' do
    allow(EmailService).to receive(:send_confirmation).and_raise(EmailService::TimeoutError)
    expect { described_class.perform_now(order.id, order.customer_email, order.total) }.to raise_error(EmailService::TimeoutError)
  end
end
```

**Example Job Implementation:**
```ruby
# app/jobs/order_confirmation_email_job.rb
class OrderConfirmationEmailJob < ApplicationJob
  queue_as :default

  # Retry on transient errors
  retry_on EmailService::TimeoutError, wait: :exponentially_longer, attempts: 5
  retry_on EmailService::RateLimitError, wait: :exponentially_longer, attempts: 3

  # Discard on permanent errors
  discard_on ActiveRecord::RecordNotFound
  discard_on EmailService::InvalidEmailError

  def perform(order_id, customer_email, order_total)
    order = Order.find(order_id)

    # Idempotency check
    return if order.email_sent_at.present?

    # Send email
    EmailService.send_confirmation(order_id, customer_email, order_total)

    # Update timestamp
    order.update(email_sent_at: Time.current)
  rescue EmailService::TimeoutError, EmailService::RateLimitError => e
    Rails.logger.error("Email service error: #{e.message}")
    Rails.logger.error(e.backtrace.first(5).join("\n"))
    raise # Will trigger retry
  rescue ActiveRecord::RecordNotFound, EmailService::InvalidEmailError => e
    Rails.logger.warn("Permanent email error: #{e.message}")
    # Will trigger discard
  end
end
```

---

### Phase 3: Retry/Discard Configuration

**Objective:** Configure robust retry and discard strategies for production reliability.

**Steps:**
1. **skills/infrastructure/implement-background-job** — Configure job infrastructure:
   - Choose queue backend (Solid Queue for Rails 8+, Sidekiq for scale)
   - Configure worker processes and concurrency
   - Set up job monitoring and alerting
2. **Retry Strategy** — Configure retry behavior:
   - `retry_on` for transient errors (network timeouts, rate limits)
   - Exponential backoff for retries
   - Maximum retry attempts
3. **Discard Strategy** — Configure discard behavior:
   - `discard_on` for permanent errors (not found, invalid data)
   - Error logging for discarded jobs
   - Alerting for discarded jobs if critical
4. **Timeout Configuration** — Set appropriate timeouts:
   - Job execution timeout
   - Queue timeout
   - Worker timeout

**Retry Strategy Guidelines:**
- Use exponential backoff for retries
- Set appropriate retry limits (3-5 for most cases)
- Don't retry permanent errors
- Log all retry attempts
- Monitor retry patterns

**HARD GATE — Retry Strategy Configured:**
- Transient errors identified and configured for retry
- Permanent errors identified and configured for discard
- Retry limits and backoff strategy configured
- Error logging configured
- Timeout values set appropriately
- Monitoring and alerting configured

**If gate fails:** Job is not production-ready. Configure retry/discard strategy.

**Example Configuration (Solid Queue - Rails 8+):**
```ruby
# config/initializers/solid_queue.rb
Rails.application.config.after_initialize do
  SolidQueue.configure do |config|
    config.worker = {
      processes: 2,
      threads: 5,
      polling_interval: 1
    }
  end
end

# config/recurring.yml
order_confirmation_cleanup:
  class: OrderConfirmationCleanupJob
  schedule: every 1.day
  queue: critical
```

**Example Configuration (Sidekiq):**
```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV['REDIS_URL'] }
  config.server_middleware do |chain|
    chain.add Sidekiq::Throttler, rate: { limit: 100, period: 1.minute }
  end
end

# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  # Default retry configuration
  retry_on StandardError, wait: :exponentially_longer, attempts: 5
end
```

---

### Phase 4: Testing & Monitoring

**Objective:** Test failure scenarios and set up production monitoring.

**Steps:**
1. **Failure Scenario Testing** — Test job behavior under failure conditions:
   - Test retry behavior (inject transient errors)
   - Test discard behavior (inject permanent errors)
   - Test timeout handling
   - Test queue full scenarios
2. **Monitoring Setup** — Configure production monitoring:
   - Job execution metrics (success/failure rates)
   - Queue depth monitoring
   - Worker health monitoring
   - Error tracking and alerting
3. **Performance Testing** — Verify job performance under load:
   - Test with expected data volume
   - Measure job execution time
   - Verify queue throughput
   - Test concurrent job execution

**HARD GATE — Failure Scenarios Tested:**
- Retry behavior tested and working
- Discard behavior tested and working
- Timeout handling tested
- Error logging verified
- Monitoring configured and tested
- Performance acceptable under load

**If gate fails:** Job is not production-ready. Address failure scenarios.

**Example Failure Scenario Tests:**
```ruby
# spec/jobs/order_confirmation_email_job_failure_spec.rb
RSpec.describe OrderConfirmationEmailJob, :focus do
  let(:order) { create(:order, :completed) }

  it 'retries on transient errors' do
    allow(EmailService).to receive(:send_confirmation)
      .and_raise(EmailService::TimeoutError)
      .then_return(true)

    expect(EmailService).to receive(:send_confirmation).twice
    described_class.perform_now(order.id, order.customer_email, order.total)
  end

  it 'discards on permanent errors' do
    allow(EmailService).to receive(:send_confirmation)
      .and_raise(EmailService::InvalidEmailError)

    expect(EmailService).to receive(:send_confirmation).once
    expect { described_class.perform_now(order.id, "invalid-email", order.total) }.not_to raise_error
  end

  it 'logs retry attempts' do
    allow(EmailService).to receive(:send_confirmation)
      .and_raise(EmailService::TimeoutError)

    expect(Rails.logger).to receive(:error).with(/Email service error/)
    described_class.perform_now(order.id, order.customer_email, order.total)
  end
end
```

**Example Monitoring Setup:**
```ruby
# app/jobs/application_job.rb
class ApplicationJob < ActiveJob::Base
  around_perform do |job, block|
    start_time = Time.current
    block.call
    duration = Time.current - start_time

    # Track job metrics
    StatsD.timing("jobs.#{job.class.name.underscore}.duration", duration)
    StatsD.increment("jobs.#{job.class.name.underscore}.success")
  rescue StandardError => e
    StatsD.increment("jobs.#{job.class.name.underscore}.failure")
    raise
  end
end
```

---

## Integration

| Predecessor | This Agent | Successor |
|-------------|------------|-----------|
| implement-background-job | background-job | production-monitoring |
| tdd | background-job | quality |
| None (standalone) | background-job | deployment |

## When to Use This vs. Individual Skills

- **Full background job lifecycle (all phases):** Use this agent
- **Only configure job infrastructure:** Use `implement-background-job`
- **Only implement job logic:** Use TDD approach directly
- **Not sure about job requirements:** Use `implement-background-job` first

## HARD-GATE: Production Readiness

**NEVER deploy background job to production before:**
- Job designed with idempotency in mind
- Tests pass (including failure scenarios)
- Retry strategy configured for transient errors
- Discard strategy configured for permanent errors
- Error logging and monitoring configured
- Performance tested under expected load
- Timeout values configured appropriately

**If gate fails:** Job is not production-ready. Address issues before deployment.

## Error Recovery

**If job fails repeatedly in production:**
1. **Monitor Alerts** — Check retry patterns and error rates
2. **Analyze Logs** — Review error messages and stack traces
3. **Classify Error** — Determine if transient or permanent
4. **Adjust Strategy** — Update retry/discard configuration if needed
5. **Fix Root Cause** — Address underlying issue in job or dependencies
6. **Redeploy** — Deploy updated job with new configuration

**If queue backs up:**
1. **Scale Workers** — Increase worker processes/threads
2. **Adjust Priorities** — Move critical jobs to higher-priority queue
3. **Optimize Jobs** — Reduce job execution time or data volume
4. **Add Monitoring** — Set up alerts for queue depth

## Output Style

```markdown
# Background Job Implementation Report — [Date]

## Job
- **Name:** OrderConfirmationEmailJob
- **Purpose:** Send order confirmation emails
- **Trigger:** Order.status = 'completed'
- **Queue:** default

## Design
- **Idempotency:** ✓ Implemented (email_sent_at check)
- **Error Classification:** ✓ Complete
- **Transient Errors:** Timeout, RateLimit (retry)
- **Permanent Errors:** RecordNotFound, InvalidEmail (discard)

## Implementation
- **Job Tests:** 3/3 passing
- **Idempotency Tests:** ✓ PASS
- **Failure Scenario Tests:** ✓ PASS
- **Total Coverage:** 95%

## Configuration
- **Retry Strategy:** ✓ Configured (exponential backoff, 5 attempts)
- **Discard Strategy:** ✓ Configured (permanent errors)
- **Timeouts:** ✓ Configured (30 seconds)
- **Monitoring:** ✓ Configured (StatsD metrics)
- **Workers:** ✓ Configured (2 processes, 5 threads each)

## Performance
- **Execution Time:** 1.2 seconds (acceptable)
- **Throughput:** 100 jobs/minute
- **Concurrent Jobs:** ✓ Tested (10 concurrent jobs)
- **Load Test:** ✓ PASS

## Status
**PRODUCTION READY** — All failure scenarios tested, monitoring configured
```

## Anti-Patterns to Avoid

- **Non-idempotent jobs:** Never implement jobs that can't be safely retried
- **Missing error handling:** Never deploy jobs without retry/discard strategy
- **Silent failures:** Always log errors and set up monitoring
- **Infinite retries:** Configure appropriate retry limits
- **Blocking operations:** Keep jobs short and non-blocking
- **Missing monitoring:** Never deploy jobs without production monitoring