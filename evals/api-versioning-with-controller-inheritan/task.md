# Upgrading the Users API to V2

## Problem/Feature Description

Your team runs a public REST API for a SaaS product. The `/api/v1/users` endpoint is consumed by several external clients and a mobile app. Product has decided to extend the user resource to include a `phone` field and restructure the response to nest the user's address details under an `address` object. These changes are not backward compatible with the current V1 response shape, so a new API version is required.

The engineering lead wants the old V1 endpoints to remain fully functional for existing clients while the new V2 endpoint becomes the forward-looking standard. V1 must eventually be retired, but clients need advance notice and time to migrate. The team follows a standard Rails project layout and uses RSpec for testing.

Your job is to design and document the versioning approach, produce the relevant Rails code, and ensure that any client still using V1 routes receives appropriate signals that the old version has a limited future. Include any tests that protect existing clients from silent regressions.

## Output Specification

Produce working Rails code for the versioned API in the expected directory layout. At a minimum, create:

- Route configuration for both API versions
- Controller files for V1 and V2
- Any reusable Rails concerns or modules required by the implementation
- Request specs that protect the existing V1 contract
- `versioning_notes.md` — a short document (bullet list is fine) covering: which versioning strategy was chosen, why, and what a reasonable retirement timeline looks like for V1

## Input Files

The following skeleton files are provided as starting points. Extract them before beginning.

=============== FILE: app/controllers/application_controller.rb ===============
class ApplicationController < ActionController::API
  # Base controller — add shared concerns here
end
=============== END FILE ===============

=============== FILE: app/models/user.rb ===============
class User < ApplicationRecord
  # Attributes: id, name, email, phone, street, city, country
  # All attributes are plain columns — no special serialization
end
=============== END FILE ===============
