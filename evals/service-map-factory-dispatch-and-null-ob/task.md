# Shipping Cost Calculator for Parcel Pro

## Problem/Feature Description

Parcel Pro is a fulfillment platform that integrates with multiple carrier tiers. Each shipment belongs to a carrier contract with a named tier: `standard`, `express`, or `overnight`. The billing team has asked for a shipping cost calculator service that takes a shipment record and returns the calculated cost as a decimal — or nothing at all if the shipment's carrier contract is inactive, unknown, or nil.

The existing codebase handles pricing with inline conditionals scattered across two controllers and a background job, which makes the logic difficult to test and impossible to extend when a new carrier tier is negotiated. The engineering lead wants a clean module-based implementation where each tier has its own class, the selection logic is centralized, and an unknown or inactive tier silently produces no cost rather than raising an error. Future tiers should require no changes to the selection mechanism itself.

Each tier has different pricing logic:
- **Standard**: flat rate of $4.99 plus $0.10 per 100g of weight
- **Express**: flat rate of $12.00 plus $0.25 per 100g of weight
- **Overnight**: flat rate of $29.99 plus $0.50 per 100g of weight

A shipment with a `nil` carrier contract, an inactive contract, or an unrecognized tier name must produce a nil result without raising.

## Output Specification

Produce the following files:

- **`app/services/shipping_calculator/`** — the full module with factory, base, null, and concrete service files
- **`spec/services/shipping_calculator/`** — RSpec specs covering factory dispatch for each tier, the null/unknown path, and at least one cost calculation assertion per tier

The shipment model has these relevant attributes: `weight_grams` (integer), `carrier_contract` (object with `active?` boolean and `tier` string).
