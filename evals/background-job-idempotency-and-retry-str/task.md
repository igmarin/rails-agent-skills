# Invoice Payment Reminder Jobs

## Problem/Feature Description

The billing team at FinTrack, a SaaS accounting platform, needs automated payment reminders sent to customers with overdue invoices. Currently, a manual process runs each morning to email customers, but it's error-prone and has caused double-charges in the past when retries fired unexpectedly. The engineering team has decided to move this to a background job system.

The application is a Rails 8 app already configured with a working mailer (`InvoiceMailer`) and an `Invoice` model with the following relevant attributes: `id`, `customer_id`, `reminder_sent_at` (timestamp, nil until reminder is sent), `status` (string, values: "pending", "paid", "overdue"). The platform also needs a nightly sweep that finds overdue invoices and enqueues reminders for each one.

Your task is to implement two Active Job classes:
1. `SendInvoiceReminderJob` — sends the reminder email for a single invoice and marks it as reminded
2. `NightlyOverdueInvoiceSweepJob` — scans for overdue invoices and enqueues a reminder job for each

The sweep job must run nightly at 08:00 UTC. The team has had painful incidents with jobs running multiple times due to queue failures, so reliability is a top priority.

## Output Specification

Produce the following files:

- `app/jobs/send_invoice_reminder_job.rb` — the reminder job implementation
- `app/jobs/nightly_overdue_invoice_sweep_job.rb` — the sweep job implementation
- `config/recurring.yml` — schedule configuration for the nightly sweep
- `spec/jobs/send_invoice_reminder_job_spec.rb` — RSpec spec for the reminder job
- `spec/jobs/nightly_overdue_invoice_sweep_job_spec.rb` — RSpec spec for the sweep job
- `process_log.md` — a brief log of implementation decisions made (e.g. idempotency approach, error handling choices, backend choice)
