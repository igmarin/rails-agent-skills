# Fitness Class Booking System

## Problem/Feature Description

An online fitness platform is launching a class booking feature. Users can reserve spots in group fitness sessions through the platform's API. The backend team has built the feature but left the test coverage incomplete.

Two distinct behaviors need to be covered:

1. **Endpoint behavior**: A `POST /bookings` endpoint that accepts a class ID and quantity, delegates to a `Bookings::CreateService`, and returns appropriate HTTP responses. The endpoint should be covered for at least three scenarios: a successful booking, a booking that fails because the class is full, and an attempt to book a class the user has already reserved.

2. **Model domain rule**: The `Booking` model enforces a uniqueness constraint — a user cannot hold more than one active booking for the same fitness class. This uniqueness validation lives on the model and must be confirmed by a test.

Your task is to write the spec coverage for both behaviors. The endpoint behavior and the model domain rule each represent a different kind of concern — consider the most appropriate spec type for each.

## Output Specification

Produce spec files with realistic content:

- One spec file covering the `POST /bookings` endpoint behavior
- One spec file covering the `Booking` model's uniqueness validation

Use `create` and `build` factory helper calls where needed (actual factory definitions are not required — add a `# TODO: define factory :booking` comment at the top of any spec that would need one). Do not create a full Rails app — just the spec files with proper structure, realistic examples, and the correct file paths.
