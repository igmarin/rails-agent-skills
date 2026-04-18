Title: Fix order total rounding error

Description:
When applying percentage discounts to orders with multiple line items, totals are rounding inconsistently causing a mismatch between displayed total and sum of line items.

Steps to reproduce:
1. Create cart with items: A (price 199.99, qty 1), B (price 49.50, qty 2)
2. Apply discount code 'MULTI5' (5%)
3. Place order and observe total displayed vs sum of line items

Acceptance criteria:
- Add unit test reproducing mismatch
- Fix rounding logic so displayed total equals sum of adjusted line items
- Add regression spec

Estimate: 2

Labels: bug, billing

