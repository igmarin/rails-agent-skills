# Admin User Report with Flexible Filtering and Sorting

## Problem/Feature Description

The operations team at Thornfield SaaS needs an admin endpoint to browse and export user accounts. They frequently need to view all users of a particular status (active, suspended, pending), and want to sort the list by different fields depending on what they are investigating — sometimes by sign-up date, sometimes by last activity, sometimes by email. The column and sort direction currently come directly from the request URL, because the original developer prioritized speed of delivery over everything else.

A recent internal security audit flagged this endpoint as high risk. The auditor's report noted that because query parameters flow directly into the database query, a crafted request could expose arbitrary table data or crash the query parser. The endpoint must be hardened before the next penetration test, which is scheduled in two weeks.

Implement a `UserSearch` service class that the controller can call with raw request parameters. The class must safely filter by user status and support column-based sorting from the parameters, while resisting injection attempts.

## Output Specification

Create the following file:

- `app/services/user_search.rb` — the `UserSearch` service class

The class should:
- Accept `status`, `sort_by`, and `sort_direction` parameters (which originate from HTTP request params)
- Return an ActiveRecord relation (or array) of users matching the status filter, sorted appropriately
- Support at minimum these sort columns: `email`, `created_at`, `last_sign_in_at`
- Support ascending and descending sort directions

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: db/schema.rb (excerpt) ===============
ActiveRecord::Schema[7.1].define(version: 2024_03_01_000001) do
  create_table "users", force: :cascade do |t|
    t.string   "email",            null: false
    t.string   "status",           null: false, default: "pending"
    t.datetime "last_sign_in_at"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
    t.string   "encrypted_password"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["status"], name: "index_users_on_status"
  end
end

=============== FILE: app/models/user.rb ===============
# frozen_string_literal: true

class User < ApplicationRecord
  STATUSES = %w[pending active suspended].freeze

  validates :email, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :by_status, ->(status) { where(status: status) if status.present? }
end
