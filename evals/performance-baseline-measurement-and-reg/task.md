# Fixing a Slow Dashboard Endpoint

## Problem/Feature Description

The operations team has flagged that the `/dashboard` endpoint on an internal Rails application takes several seconds to load for accounts with large datasets. The engineering manager wants the team to investigate, fix the problem, and make sure it cannot silently regress in the future.

The application is a standard Rails 7 app backed by PostgreSQL. The `DashboardController#index` action loads a list of projects, and for each project the view accesses the associated owner (a `User`) and the count of associated `Task` records. The relevant models and a simplified controller are provided below.

Produce a thorough write-up of your findings and the work done so a future developer can understand what the problem was and how it was addressed. Do not leave any large generated files on disk.

## Output Specification

Produce the following files:

- `performance_analysis.md` — your written analysis: what you observed about the slow query behaviour, what change you made and why, and evidence from the PostgreSQL query planner confirming the improvement
- An updated `app/controllers/dashboard_controller.rb` with the fix applied
- `spec/performance/dashboard_spec.rb` — a spec that will catch the problem if it ever comes back
- `db/migrate/<timestamp>_add_index_for_dashboard.rb` — a migration adding any index that supports the fix (if no index is needed, omit this file and note why in `performance_analysis.md`)

## Input Files

The following files represent the current state of the application. Extract them before beginning.

=============== FILE: app/models/project.rb ===============
class Project < ApplicationRecord
  belongs_to :owner, class_name: 'User'
  has_many :tasks
end
=============== END FILE ===============

=============== FILE: app/models/user.rb ===============
class User < ApplicationRecord
  has_many :owned_projects, class_name: 'Project', foreign_key: :owner_id
end
=============== END FILE ===============

=============== FILE: app/models/task.rb ===============
class Task < ApplicationRecord
  belongs_to :project
end
=============== END FILE ===============

=============== FILE: app/controllers/dashboard_controller.rb ===============
class DashboardController < ApplicationController
  def index
    @projects = Project.all
  end
end
=============== END FILE ===============

=============== FILE: app/views/dashboard/index.html.erb ===============
<% @projects.each do |project| %>
  <div>
    <h2><%= project.name %></h2>
    <p>Owner: <%= project.owner.name %></p>
    <p>Tasks: <%= project.tasks.count %></p>
  </div>
<% end %>
=============== END FILE ===============
