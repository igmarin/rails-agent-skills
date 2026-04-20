# Authorization Overhaul for a Multi-Tenant Project Management App

## Problem/Feature Description

A project management Rails application allows teams to collaborate on Projects. A security audit found serious authorization gaps: the current implementation only checks `current_user.present?` before allowing destructive operations — meaning any authenticated user can delete any project, not just their own. The auditors flagged this as a critical vulnerability.

The `User` model has an `admin` boolean attribute. The `Project` model has a `owner_id` foreign key linking to the user who created it. Business rules are: project owners may read, update, and destroy their own projects; admins may perform any action on any project; authenticated non-owners may read projects but not modify or destroy them; unauthenticated visitors cannot access projects at all.

Your job is to replace the existing flawed authorization with a proper implementation using Pundit, and deliver comprehensive specs that prove every role and edge case is covered.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: app/controllers/projects_controller.rb ===============
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:show, :update, :destroy]

  def index
    @projects = Project.all
  end

  def show
    render json: @project
  end

  def create
    if current_user.present?
      @project = current_user.projects.build(project_params)
      if @project.save
        render json: @project, status: :created
      else
        render json: @project.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def update
    if current_user.present?
      if @project.update(project_params)
        render json: @project
      else
        render json: @project.errors, status: :unprocessable_entity
      end
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  def destroy
    if current_user.present?
      @project.destroy
      head :no_content
    else
      render json: { error: 'Unauthorized' }, status: :unauthorized
    end
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:name, :description)
  end
end

## Output Specification

Produce the following files:

- `app/policies/project_policy.rb` — the corrected Pundit policy
- `app/controllers/projects_controller.rb` — the refactored controller
- `spec/policies/project_policy_spec.rb` — comprehensive policy spec
- `spec/requests/projects_spec.rb` — request spec exercising all roles against the most sensitive actions (update and destroy)
- `implementation_notes.md` — a brief description of what was wrong with the original code and how it was fixed
