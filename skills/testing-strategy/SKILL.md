---
name: testing-strategy
description: Writing tests that must fail when code breaks. Use when planning or writing any tests.
---

# Contract-Based Testing

Every test must fail if the code it tests is deleted or broken.

## The Three Questions

Answer these before writing any test.

### 1. The Contract Question

"What does this code PROMISE to do?"

Not "what does it do" but "what would break downstream if it stopped doing it?"

### 2. The Deletion Test

"If I delete this code, does this test fail?"

If no: the test is useless. Don't write it.

### 3. The Bug Detection Test

"What three real bugs would this test catch?"

If you can't name three: the test is too weak.

## What a Real Test Looks Like

```python
# CONTRACT: process_order charges the card and creates a record
def test_process_order_charges_card_and_records():
    # Use a real test server or service stub, not a mock that returns what you told it
    result = process_order(order_id="123", amount=50.00)

    # Verify the contract (what callers actually depend on)
    assert result.status == "completed"
    assert result.charge_id is not None

    # Verify side effects
    assert db.get_order("123").status == "completed"
    assert payment_log.last_charge() == 50.00

    # BUGS THIS CATCHES:
    # 1. Wrong charge amount
    # 2. Missing database write
    # 3. Status not set after successful charge
```

This test fails if `process_order` is deleted, its charge logic is broken, or its database write is skipped.

## The Forbidden Pattern

```python
# FORBIDDEN: mock-returns-mock
mock_service.charge.return_value = {"id": "ch_123"}
result = process_order(order_id="123", amount=50.00)
assert result.charge_id == "ch_123"  # Circular: tests the mock, not the code
```

This passes if the real code is deleted. It configures a mock to return X, then asserts the result is X. It tests nothing.

## Pre-Test Checklist

Before writing any test:

- What is the contract? Write it as a comment above the test.
- List three bugs this test catches. If you can't, redesign it.
- Would this test fail if the function were deleted? If not, start over.
- Are you testing behavior, not implementation?
- Are all side effects verified (storage, logs, state changes)?
- Are error paths covered, not just happy path?
- Are edge cases covered (empty, null, boundary values)?
- Run `/verification-workflow` to confirm the test fails before the fix and passes after. That BEFORE/AFTER is the proof it catches real bugs.

## Anti-Patterns

- Mock-returns-mock: configuring a mock to return X, then asserting the result is X. This tests nothing.
- "Was called" assertions without verifying what was called with or what the result was.
- "Is defined" assertions when the actual value is known and testable.
- Testing framework or library behavior instead of your code.
- Coupling tests to implementation details (internal function calls, private state).
- Only testing the happy path. Error paths have contracts too.

## The Floor

A test suite that passes when code is deleted is not a safety net. It is theater. The deletion test is the single most important quality gate: if you cannot delete a function and watch a test fail, the test is not covering that function. Apply the contract question to every test before writing it. The three questions are not ceremony. They are the mechanism that separates tests that catch bugs from tests that only pass.
