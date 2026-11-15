---
name: disproving-audit-findings
description: Tests the findings of a code review or audit (bugs, security holes, load failures, untested risky code, slow paths, delete, merge or split advice) with reproduction tests, to discard false positives. Load at the end of any audit or review that produced findings, then ask the user whether to test them; also use when the user asks to verify an existing report empirically. Not for performing the review, fixing findings or running the full test suite.
license: MIT
compatibility: Needs an audit report (from a review or audit skill, subagent or the user), a project test framework with its runner, and ideally a way to dispatch subagents (otherwise this skill writes and runs the tests itself). Never production access.
---

# Disproving audit findings

An audit report is a set of claims. Test each one. A claim that cannot be reproduced is reported as a false positive so later work does not build on it.

Terms: **finding** = one claim in the report. **Reproduction test** = a test whose assertions describe the defect and PASS while the defect is present (it fails if the defect is absent). **Confirmed** = the reproduction test passed and exercises the claimed behavior. **False positive** = a correct reproduction test fails because the claimed behavior does not occur.

Track: 1 get the report (ask the user first), 2 write tests, 3 review every test (yourself), 4 run filtered tests, 5 report.

## 1. Get the report and ask the user

**Loaded at the end of an audit or review:** the report is already in the conversation. Do not rerun the audit. Before writing any test, ask the user (a question tool, else inline):

- Test the findings? Default: yes, all of them.
- Which ones, if not all: by severity, by finding id, or a pick list.
- Test location: the project's test directory (default), or a scratch location to discard afterward.

Stop if the user declines. Tests cost time and add files, so the user decides.

**Loaded on request, no report in hand:** inspect the skills and subagents available (listings plus any search tool) and select those whose purpose is reviewing or auditing code; judge by description, not name; exclude this skill. A report the user already has counts as the output of this step.

- None found: stop and tell the user to request a review or audit first. Never perform the audit yourself.
- One: use it. Several: ask the user which, listing each with its one-line description; ask from the main conversation, since subagents cannot ask.

Invoke it on the scope the user named; with no scope use the audit's default and state it in the report. Wait for the full report, then ask the questions above.

## 2. Write reproduction tests

1. Split the report (the findings the user chose) into findings F1, F2, ... Keep the audit's wording and `path:line` receipts, and note which findings cite or assume another.
2. Mark a finding **Not testable** only with a stated reason (for example, a pure style opinion). Delete, merge and split advice is testable: prove no references exist, prove two units behave identically, or show a unit mixes concerns its tests must stub together.
3. Delegate test writing to a subagent when one exists, started fresh so no context leaks in, else write them yourself. The brief contains: the finding verbatim with `path:line`; the repository's test framework, conventions and test directory (discovered from the repo, not guessed); the rule that assertions encode the defect and pass when it is present; no production-code edits and no mocking away the code under test; the exact command to run that file or test; for load, race or performance findings, a bounded deterministic reproduction (fixed iteration counts, explicit timeouts, a measured threshold with the reason for its value); and a request to return test paths and names per finding.
4. Group findings per subagent only when they touch the same area; otherwise one finding per brief.

## 3. Review every test yourself

A weak test can make a valid finding look false. For each test check that it:
- reaches the code path the finding names;
- asserts the claimed symptom, not a proxy;
- is not tautological and would fail without the defect;
- keeps the defect's condition (setup, mocks and fixtures do not remove it);
- is deterministic (no timing luck, ordering or shared state);
- touches no production data, services or credentials.

Send a failing review back with the specific flaw, up to two correction rounds per finding, then mark it **Inconclusive** with the reason.

## 4. Run the tests

Run only the new reproduction tests, filtered by file or name with the project's own runner (read it from the project, never assume). Delegate running when possible, again fresh, asking for raw output per test. Never run the whole suite or anything against production resources.

| Outcome | Meaning |
| --- | --- |
| Passes | Confirmed |
| Fails on the assertion that encodes the defect | False positive; keep the failure output, after one more look that the test premise is right |
| Errors in setup, syntax or a missing dependency | A test defect, not a verdict; back to step 3 |

For every Confirmed finding, state whether the repro scenario is minimal; where it is not, list the elements still load-bearing for the failure, so the user knows what the confirmation actually rests on.

## 5. Report

To the user, only this table and the notes below it.

| Finding | Test location | Result |
| --- | --- | --- |
| F1 short name | `tests/Foo/BarTest.php::test_name` | Confirmed: one-line observed evidence |
| F2 short name | `tests/...` | False positive: failure sample (a few lines at most) |
| F3 short name | none | Not testable / Inconclusive: reason |

Notes: for every Confirmed finding, say whether its repro is minimal and name any load-bearing elements (step 4); list every finding that depends on a false positive so the user knows what to distrust; state the audit used and the scope tested; say where the tests were left; production code was not changed.

## Hard rules

- Assert a result only after running the test, quoting observed output.
- Never perform or rewrite the audit, and never modify production code.
- Never call a finding a false positive from a test that failed to run or that you did not review.
- Stop and ask if a test would need production access, destructive operations or unbounded load.
