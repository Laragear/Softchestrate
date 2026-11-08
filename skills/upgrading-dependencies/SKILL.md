---
name: upgrading-dependencies
description: Moves one package, library or framework to a new version, including a new major version. Reads the release notes and upgrade guide, maps each breaking change to the code and configuration that use it, updates version constraints and the supported-versions matrix, and proves the result with the project's own checks. Use when the user asks to upgrade, bump, update, migrate to a new major version, drop or add support for a runtime or framework version, or make the project work with a newer dependency, even for one package. Not for diagnosing a failing build (build-doctor) or publishing the result (deploying-builds).
license: MIT
---

# Upgrading Dependencies

Move one dependency to a target version and prove the result with the project's own checks. The user chooses the target. This skill finds what the move breaks and fixes what the project uses.

## Scope

- One dependency per run. Upgrades that must move together go through `planning-implementations` first.
- A failing install or build after the change: dispatch `build-doctor` with the exact failing command and the log path.
- Publishing the new version: hand the artifact and destination to `deploying-builds`.

## Procedure

1. **Fix the range and the matrix.** Note the current version, the target (the latest stable release if the user named none), and the runtime and framework versions the project supports. Read them from the manifest, CI configuration and docs. If the target drops a runtime or framework the project still supports, stop and ask the user.
2. **List every breaking change.** Read the release notes, changelog and upgrade guide for each version between the current one and the target, not only the last. Write one line per change: what changed, the old and new behavior, and the API, configuration key or behavior it affects. Include deprecations the target removes.
3. **Map each change to the project.** Search the source, tests and configuration for each affected name, key and behavior. Record a change with no project usage as `not used`, with the search that showed it. Never drop a change silently.
4. **Update the constraint and the lockfile.** Change the constraint in the manifest, then let the package manager update the lockfile with its own command. Never edit a lockfile by hand. If another dependency pins the package to an older version, report the conflict and ask the user before changing that dependency.
5. **Apply only what the mapped list needs.** Tie each code change to a line in the list. Do not restructure code around the upgrade; that is `refactoring-code`.
6. **Keep the matrix honest.** A library's constraints are promises to its users. Widen them only to versions the CI tests, and narrow them when a supported runtime or framework is dropped.
7. **Verify with the project's checks.** Run its install, static analysis and test suite as the project defines them. Delegate the test run to `test-runner` (`mode: triage`) when the suite is large. Where a changed behavior has no test, name the gap in the report, and when the gap sits on a path the project exercises, offer a differential check as evidence: run a representative input or workload through the old version and the new, then diff the outputs.

## Output

- The from and to versions, with the source of the target.
- A table: change, status (`applied`, `not used` or `deferred`), `path:line` where it applies, and the reason for any deferral.
- Changed files.
- Checks run and their results, and checks not run.
- The supported-versions matrix before and after.
