---
name: testing
description: Use to choose and apply TDD or BDD based on the change, enforcing fast Red-Green-Refactor and Given-When-Then loops.
---

# Testing

This skill guides when and how to use Test Driven Development (TDD) and Behavior Driven Development (BDD), and how to switch between them while iterating quickly.

## Purpose

Use TDD to design and verify internal behavior with fast feedback. Use BDD to define user-visible behavior, workflows, and acceptance criteria. Switch based on scope, not preference.

## When to Use This Skill

Use this skill when:

- Adding new features, flows, or APIs
- Fixing bugs or regressions
- Refactoring behavior or changing requirements
- Adding tests to untested code

## Core Principles

- No production code without a failing test first
- Observe the failing test and confirm the failure is meaningful
- Keep tests focused on behavior, not implementation
- Prefer the smallest loop that proves the next behavior

## Choosing TDD vs BDD

### Use TDD When

- Building internal logic, helpers, or algorithms
- Defining module-level behavior and edge cases
- Refactoring with tight feedback loops
- You can describe success as a precise input/output rule

### Use BDD When

- Behavior spans multiple components or layers
- Stakeholders care about readable acceptance criteria
- The change is user-facing or workflow-driven
- You need to agree on behavior before implementation

### Switching Rules

- Start with BDD for a feature, then use TDD for each supporting component
- Switch from TDD to BDD when behavior needs cross-module coordination
- Switch from BDD to TDD when a step requires precise edge-case rules

## Fast Iteration Loop

Follow the smallest loop possible and only expand when needed.

1. Pick one behavior
2. Write a failing test (TDD unit or BDD scenario)
3. Run the smallest test command and observe failure
4. Write minimal code to pass
5. Run the smallest test command and observe success
6. Refactor while green

## TDD Loop (Red-Green-Refactor)

### Red

Write one failing test that proves the next behavior.

```go
func TestRetryStopsAfterThreeFailures(t *testing.T) {
    attempts := 0
    err := Retry(func() error {
        attempts++
        return errors.New("fail")
    })

    if err == nil {
        t.Fatalf("expected error")
    }
    if attempts != 3 {
        t.Fatalf("expected 3 attempts, got %d", attempts)
    }
}
```

### Green

Write the smallest code to make the test pass.

### Refactor

Clean up naming, structure, and duplication while tests stay green.

## BDD Loop (Given-When-Then)

### Write a Scenario

Define behavior in business terms first.

```gherkin
Scenario: lock account after failed logins
  Given a user account exists
  And the user has failed login attempts
  When the user fails login again
  Then the account is locked
```

### Prove Failure

Run the scenario and ensure it fails for the right reason.

### Implement the Step Behavior

Use TDD for each step definition or supporting module.

## Minimum Evidence Rules

- A passing test that never failed does not count
- A scenario that fails for setup errors does not count
- A test that checks mocks instead of behavior does not count

## Anti-Patterns to Avoid

- Writing implementation first, tests later
- Over-mocking instead of testing real behavior
- One test covering multiple unrelated behaviors
- Large BDD scenarios that hide missing unit behavior
- Refactoring before the green phase

## Decision Checklist

Before implementing, confirm:

- Is the behavior user-visible or cross-module? Start with BDD
- Is the behavior a small rule or edge case? Start with TDD
- Can the behavior be explained in Given-When-Then? Use BDD
- Can the behavior be proven by a single function test? Use TDD

## Example Workflow

1. Write a BDD scenario for the feature
2. Implement each step using TDD unit tests
3. Re-run the scenario to validate end-to-end behavior
4. Refactor once all tests stay green

## Completion Criteria

- Every new behavior has a failing test observed first
- BDD scenarios match acceptance criteria language
- TDD tests cover edge cases and error paths
- All tests pass with clean output
