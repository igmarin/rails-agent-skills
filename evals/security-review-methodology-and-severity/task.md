# Document Search Security Audit

## Problem/Feature Description

A legal technology company is preparing for a security audit before onboarding enterprise customers. Their Rails application includes a document management module that was written quickly by a contractor. The CTO has asked for a thorough security assessment of the module's code before it touches any client data.

The engineering team needs a written security review they can share with their auditors and use to prioritise remediation work. The review should be actionable — auditors want to understand exactly what can go wrong and how an attacker would exploit each issue, not just a list of abstract best-practice suggestions.

Produce a security review of the code provided below. Save the review as `security-review.md`.

## Input Files

The following files are provided as inputs. Extract them before beginning.

=============== FILE: app/controllers/documents_controller.rb ===============
class DocumentsController < ApplicationController
  def index
    query = params[:search]
    @documents = Document.where("title LIKE '%#{query}%' OR body LIKE '%#{query}%'")
    render :index
  end

  def show
    @document = Document.find(params[:id])
    render :show
  end

  def update
    @document = Document.find(params[:id])
    @document.update(params[:document])
    redirect_to @document
  end

  def destroy
    @document = Document.find(params[:id])
    @document.destroy
    redirect_to documents_path
  end

  def download
    @document = Document.find(params[:id])
    file_path = Rails.root.join('storage', params[:filename])
    send_file file_path
  end
end

=============== FILE: app/models/document.rb ===============
class Document < ApplicationRecord
  belongs_to :user
  has_many :document_versions

  after_save :log_access

  def log_access
    Rails.logger.info("Document accessed: #{self.inspect}")
  end

  def self.search_for_user(user_id, term)
    where("user_id = #{user_id} AND title ILIKE ?", "%#{term}%")
  end
end

=============== FILE: config/initializers/api_keys.rb ===============
SENDGRID_API_KEY = "SG.abc123xyz789secretkey"
STRIPE_SECRET_KEY = "sk_live_realproductionkey999"
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
