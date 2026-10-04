# TDD Conventions

This file defines mandatory conventions for all current and future `TDD_F*.md` files.

## 1) File location and naming

- All TDD phase files must live in `TDD/`.
- Naming format is `TDD_F{N}.md` where `{N}` is the phase number (`0..n`).

## 2) Mandatory metadata header

Each TDD file must include these lines near the top:

- `> Phase: N`
- `> Track: ...`
- `> Status: ...`
- `> Source: `lf_specs/phase_N_definition.md``

## 3) Source reference rule

- The `Source` field must always reference the matching phase definition file using this exact relative pattern:
  - `lf_specs/phase_N_definition.md`
- Entry-gate references inside the body must use the same full path.

## 4) Minimum section structure

Each TDD must contain, at minimum:

1. Test objective
2. Scope under test
3. Out of scope
4. Assumptions
5. Fixtures/test data
6. Given/When/Then matrix
7. Negative and edge cases
8. Green criteria
9. Coverage target
10. Risks covered / not covered
11. Evidence required
12. Execution order (TDD cycle)
13. Entry and exit gates

## 5) Governance

- Do not implement code from a TDD artifact.
- Use TDD artifacts strictly for planning, verification design, and phase gating.
- Future TDD files must comply with this convention before review/approval.
