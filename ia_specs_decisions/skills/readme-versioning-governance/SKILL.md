---
name: readme-versioning-governance
description: Keeps README and CHANGELOG consistent with repository mission and X.Y.Z versioning policy; use when scope, releases, or documentation governance changes.
metadata:
  short-description: README + changelog governance
---

# README & Versioning Governance

Use this skill when the user asks to update repository governance documentation (README/CHANGELOG) or define versioning rules.

## Objective

Keep consistency between:

- repository mission,
- execution/documentation strategy,
- and version management in `CHANGELOG.md`.

## Mandatory rules

1. Preserve valid existing README content and extend it without losing context.
2. Always include a repository mission section.
3. Always include the `X.Y.Z` versioning policy:
   - `Z` = fix,
   - `Y` = minor (resets Z),
   - `X` = major (resets Y and Z).
4. Ensure README links to `CHANGELOG.md`.
5. Explicitly remind that each new version requires a `CHANGELOG.md` update.
6. Keep format compatible with Keep a Changelog.

## Recommended flow

1. Read existing `README.md` and `CHANGELOG.md`.
2. Update README with mission + versioning/changelog policy (if missing).
3. Create or update `CHANGELOG.md` with:
   - header,
   - versioning policy,
   - `[Unreleased]` section,
   - latest published version.
4. Verify UTF-8 encoding and absence of corrupted characters.

## Do not

- Do not change the versioning policy without explicit instruction.
- Do not delete previous changelog history.
- Do not shift repository focus to a different product.
